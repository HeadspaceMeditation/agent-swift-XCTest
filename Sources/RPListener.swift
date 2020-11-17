//
//  Listener.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Windmill Smart Solutions on 5/12/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation
import XCTest

public class RPListener: NSObject, XCTestObservation {

  private var reportingService: ReportingService!
  private let queue = DispatchQueue(label: "com.report_portal.reporting", qos: .utility)
  private var configuration: AgentConfiguration!
  private var shouldPublishData = false

  public override init() {
    super.init()

    XCTestObservationCenter.shared.addTestObserver(self)
  }

  private func readConfiguration(from testBundle: Bundle) -> AgentConfiguration {
    guard
      let bundlePath = testBundle.path(forResource: "Info", ofType: "plist"),
      let bundleProperties = NSDictionary(contentsOfFile: bundlePath) as? [String: Any],
      let shouldReport = bundleProperties["PushTestDataToReportPortal"] as? Bool,
      let portalPath = bundleProperties["ReportPortalURL"] as? String,
      let portalURL = URL(string: portalPath),
      let projectName = bundleProperties["ReportPortalProjectName"] as? String,
      let token = bundleProperties["ReportPortalToken"] as? String,
      let shouldFinishLaunch = bundleProperties["IsFinalTestBundle"] as? Bool,
      let launchName = bundleProperties["ReportPortalLaunchName"] as? String,
      let logDirectory = bundleProperties["REMOTE_LOGGING_BASE_URL"] as? String,
      let environment = bundleProperties["ENVIRONMENT_NAME"] as? String,
      let buildVersion = bundleProperties["CFBundleShortVersionString"] as? String,
      let testRunServerName = bundleProperties["TestRunServerName"] as? String else
    {
      fatalError("Configure properties for report portal in the Info.plist")
    }

    //Determine user name/machine name which inits test run. Initially, the data looks like /Users/epamcontractor/Library/Developer/...
    //We need to extract the second value, i.e. epamcontractor for example.
    let currentServerName = String(ProcessInfo.processInfo.arguments[0].split(separator: "/")[1])   
    var tags : [[String: Any]] = TagHelper.defaultTags
    tags.append(["key": "environment", "system": false, "value": environment])
    tags.append(["key": "testType", "system": false, "value": testType.rawValue])
    tags.append(["key": "product", "system": false, "value": launchName])
    tags.append(["key": "buildVersion", "system": false, "value": buildVersion])
    tags.append(["key": "testPriority", "system": false, "value": testPriority.rawValue])
    tags.append(["key": "serverName", "system": false, "value": currentServerName])
    var launchMode: LaunchMode = .default
    if let isDebug = bundleProperties["IsDebugLaunchMode"] as? Bool, isDebug == true {
      launchMode = .debug
    }

    //Determine whether to send data to the Report Portal. Data can be sent if tests are run
    //from CircleCI or the PushTestDataToReportPortal parameter is set to YES
    let circleCIRun = currentServerName == testRunServerName
    shouldPublishData = circleCIRun || shouldReport

    return AgentConfiguration(
      reportPortalURL: portalURL,
      projectName: projectName,
      launchName: launchName,
      shouldSendReport: shouldReport,
      portalToken: token,
      tags: tags,
      shouldFinishLaunch: shouldFinishLaunch,
      launchMode: launchMode,
      logDirectory: logDirectory,
      environment: environment,
      buildVersion: buildVersion,
      testType: testType.rawValue,
      testPriority: testPriority.rawValue,
      testRunServerName: currentServerName
    )
  }

  public func testBundleWillStart(_ testBundle: Bundle) {
    self.configuration = readConfiguration(from: testBundle)

    guard shouldPublishData else {
      print("Set 'YES' for 'PushTestDataToReportPortal' property in Info.plist if you want to put data to report portal")
      return
    }
    reportingService = ReportingService(configuration: configuration)
    queue.async {
      do {
        try self.reportingService.startLaunch()
      } catch let error {
        print(error)
      }
    }
  }

  public func testSuiteWillStart(_ testSuite: XCTestSuite) {
    if shouldPublishData {
      queue.async {
        do {
          if testSuite.name.contains(".xctest") {
            try self.reportingService.startRootSuite(testSuite)
          } else {
            try self.reportingService.startTestSuite(testSuite)
          }
        } catch let error {
          print(error)
        }
      }
    }
  }

  public func testCaseWillStart(_ testCase: XCTestCase) {
    if shouldPublishData {
      queue.async {
        do {
          try self.reportingService.startTest(testCase)
        } catch let error {
          print(error)
        }
      }
    }
  }

  public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
    if shouldPublishData {
      queue.async {
        do {
          try self.reportingService.reportLog(level: "error", message: "Test '\(String(describing: testCase.name)))' failed on line \(lineNumber), \(description)")
        } catch let error {
          print(error)
        }
      }
    }
  }

  public func testCaseDidFinish(_ testCase: XCTestCase) {
    if shouldPublishData {
      queue.async {
        do {
          try self.reportingService.finishTest(testCase)
        } catch let error {
          print(error)
        }
      }
    }
  }

  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    if shouldPublishData {
      queue.async {
        do {
          if testSuite.name.contains(".xctest") {
            try self.reportingService.finishRootSuite()
          } else if !testSuite.name.contains("Selected tests") {
            try self.reportingService.finishTestSuite()
          }
        } catch let error {
          print(error)
        }
      }
    }
  }

  public func testBundleDidFinish(_ testBundle: Bundle) {
    if shouldPublishData {
      queue.sync() {
        do {
          try self.reportingService.finishLaunch()
        } catch let error {
         print(error)
        }
      }
    }
  }

  // MARK: - Environment

  enum TestType: String {
    case e2eTest
    case uiTest
  }

  enum TestPriority: String {
    case smoke
    case mat
    case regression
    case debug
    case flaky
  }

  private(set) lazy var testType: TestType = {
    let type = ProcessInfo.processInfo.environment["TestType"] ?? ""
    let other = TestType(rawValue: type) ?? .uiTest

    return other
  }()

  private(set) lazy var testPriority: TestPriority = {
    let priority = ProcessInfo.processInfo.environment["TestPriority"] ?? ""

    return TestPriority(rawValue: priority) ?? .debug
  }()
}
