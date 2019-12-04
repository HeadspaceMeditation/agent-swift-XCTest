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
      let buildVersion = bundleProperties["CFBundleShortVersionString"] as? String else
    {
      fatalError("Configure properties for report portal in the Info.plist")
    }
    var tags: [String] = []
    if let tagString = bundleProperties["ReportPortalTags"] as? String {
      tags = tagString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).components(separatedBy: ",")
    }
    tags.append(testType.rawValue)
    tags.append(launchName)
        
    var launchMode: LaunchMode = .default
    if let isDebug = bundleProperties["IsDebugLaunchMode"] as? Bool, isDebug == true {
      launchMode = .debug
    }
        
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
      testType: testType.rawValue
      )
  }
    
  public func testBundleWillStart(_ testBundle: Bundle) {
    let configuration = readConfiguration(from: testBundle)
    
    guard configuration.shouldSendReport else {
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
    guard
      !testSuite.name.contains("All tests"),
      !testSuite.name.contains("Selected tests") else
    {
      return
    }
    
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
    
  public func testCaseWillStart(_ testCase: XCTestCase) {
    queue.async {
      do {
        try self.reportingService.startTest(testCase)
      } catch let error {
        print(error)
      }
    }
  }
    
  public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
    queue.async {
      do {
        try self.reportingService.reportLog(level: "error", message: "Test '\(String(describing: testCase.name)))' failed on line \(lineNumber), \(description)")
      } catch let error {
        print(error)
      }
    }
  }
    
  public func testCaseDidFinish(_ testCase: XCTestCase) {
    queue.async {
      do {
        try self.reportingService.finishTest(testCase)
      } catch let error {
        print(error)
      }
    }
  }
    
  public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    guard
      !testSuite.name.contains("All tests"),
      !testSuite.name.contains("Selected tests") else
    {
      return
    }
    
    queue.async {
      do {
        if testSuite.name.contains(".xctest") {
          try self.reportingService.finishRootSuite()
        } else {
          try self.reportingService.finishTestSuite()
        }
      } catch let error {
        print(error)
      }
    }
  }
    
  public func testBundleDidFinish(_ testBundle: Bundle) {
    queue.sync() {
      do {
        try self.reportingService.finishLaunch()
      } catch let error {
        print(error)
      }
    }
  }
    
  // MARK: - Environment
    
  enum TestType: String {
    case e2eTest
    case uiTest
  }
    
  private(set) lazy var testType: TestType = {
    let type = ProcessInfo.processInfo.environment["TestType"] ?? ""
    let other = TestType(rawValue: type) ?? .uiTest
    
    return other
  }()
}
