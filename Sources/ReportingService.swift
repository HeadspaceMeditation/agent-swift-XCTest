//
//  RPServices.swift
//
//  Created by Stas Kirichok on 22/08/18.
//  Copyright © 2018 Windmill. All rights reserved.
//

import Foundation
import XCTest

enum ReportingServiceError: Error {
  case launchIdNotFound
  case testSuiteIdNotFound
}

class ReportingService {
    
  private let httpClient: HTTPClient
  private let configuration: AgentConfiguration
  private var fileService: FileService?
    
  private var launchID: String?
  private var testSuiteStatus = TestStatus.passed
  private var launchStatus = TestStatus.passed
  private var rootSuiteID: String?
  private var testSuiteID: String?
  private var testID = ""
    
  init(configuration: AgentConfiguration) {
    self.configuration = configuration
    let baseURL = configuration.reportPortalURL.appendingPathComponent(configuration.projectName)
    httpClient = HTTPClient(baseURL: baseURL)
    httpClient.setPlugins([AuthorizationPlugin(token: configuration.portalToken)])
    self.fileService = FileService(logsDirectory: configuration.logDirectory)
  }
    
  func startLaunch() throws {
    
    let endPoint = StartLaunchEndPoint(
      launchName: getLaunchName(),
      tags: self.configuration.tags,
      mode: self.configuration.launchMode
    )
    
    let response: Result<Launch, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
    switch response {
    case .success(let result):
      self.launchID = result.id
    case .failure(let error):
      print(error)
    }
  }
   
  func startRootSuite(_ suite: XCTestSuite) throws {
    guard let launchID = launchID else {
      throw ReportingServiceError.launchIdNotFound
    }
    
    let endPoint = StartItemEndPoint(itemName: suite.name, launchID: launchID, type: .suite)
   
    let response: Result<Item, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
    switch response {
     case .success(let result):
       self.rootSuiteID = result.id
     case .failure(let error):
       print(error)
     }
  }
    
  func startTestSuite(_ suite: XCTestSuite) throws {
    guard let launchID = launchID else {
      throw ReportingServiceError.launchIdNotFound
    }
    guard let rootSuiteID = rootSuiteID else {
      throw ReportingServiceError.launchIdNotFound
    }
    
    let endPoint = StartItemEndPoint(itemName: suite.name, parentID: rootSuiteID, launchID: launchID, type: .test)
    let response: Result<Item, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
    switch response {
     case .success(let result):
       self.testSuiteID = result.id
     case .failure(let error):
       print(error)
    }
  }
    
  func startTest(_ test: XCTestCase) throws {
    guard let launchID = launchID else {
      throw ReportingServiceError.launchIdNotFound
    }
    guard let testSuiteID = testSuiteID else {
      throw ReportingServiceError.testSuiteIdNotFound
    }
    let endPoint = StartItemEndPoint(
      itemName: extractTestName(from: test),
      parentID: testSuiteID,
      launchID: launchID,
      type: .step
    )
    
    let response: Result<Item, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
    switch response {
      case .success(let result):
        self.testID = result.id
      case .failure(let error):
        print(error)
     }
    
     self.fileService!.createLogFile(withName: extractTestName(from: test))
   }
    
  func reportLog(level: String, message: String) throws {
    let endPoint = PostLogEndPoint(itemID: testID, level: level, message: message)
    
    let _: Result<Item, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
  }
    
  func finishTest(_ test: XCTestCase) throws {
    let testStatus = test.testRun!.hasSucceeded ? TestStatus.passed : TestStatus.failed
    if testStatus == .failed {
      testSuiteStatus = .failed
      launchStatus = .failed
    }
    
    try? reportLog(level: "info", message: fileService!.readLogFile(fileName: extractTestName(from: test)))
    try? fileService!.deleteLogFile(withName: extractTestName(from: test))
    
    let endPoint = FinishItemEndPoint(itemID: testID, status: testStatus)
    
    let _: Result<Finish, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
  }
    
  func finishTestSuite() throws {
    guard let testSuiteID = testSuiteID else {
      throw ReportingServiceError.testSuiteIdNotFound
    }
    let endPoint = FinishItemEndPoint(itemID: testSuiteID, status: testSuiteStatus)
    
    let _: Result<Finish, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
  }
    
  func finishRootSuite() throws {
    guard let rootSuiteID = rootSuiteID else {
      throw ReportingServiceError.testSuiteIdNotFound
    }
    let endPoint = FinishItemEndPoint(itemID: rootSuiteID, status: launchStatus)
   
    let _: Result<Finish, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
  }
    
  func finishLaunch() throws {
    guard configuration.shouldFinishLaunch else {
      print("skip finish till next test bundle")
      return
    }
    guard let launchID = launchID else {
      throw ReportingServiceError.launchIdNotFound
    }
    let endPoint = FinishLaunchEndPoint(launchID: launchID, status: launchStatus)
    
    let _: Result<Finish, Error> = self.httpClient.synchronousCallEndPoint(endPoint)
  }
    
  func getLaunchName() -> String {
    var launchName = "iOS_" + configuration.launchName + "_" + configuration.testType
    launchName += "_" + configuration.testPriority + "_" + configuration.environment
   
    return launchName
  }
}

private extension ReportingService {
    
  func extractTestName(from test: XCTestCase) -> String {
    let originName = test.name.trimmingCharacters(in: .whitespacesAndNewlines)
    let components = originName.components(separatedBy: " ")
    let result = components[1].replacingOccurrences(of: "]", with: "")

    return result
  }
    
}

extension String {
  var isLowercased: Bool {
    return lowercased() == self
  }
}
