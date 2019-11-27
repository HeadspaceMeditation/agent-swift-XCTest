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
    
    private let semaphore = DispatchSemaphore(value: 0)
    private let timeOutForRequestExpectation = 15.0
    
    init(configuration: AgentConfiguration) {
        self.configuration = configuration
        let baseURL = configuration.reportPortalURL.appendingPathComponent(configuration.projectName)
        httpClient = HTTPClient(baseURL: baseURL)
        httpClient.setPlugins([AuthorizationPlugin(token: configuration.portalToken)])
        self.fileService = FileService(logsDirectory: configuration.logDirectory)
    }
    
    func startLaunch() throws {
        
        let endPoint = StartLaunchEndPoint(
            launchName: self.configuration.launchName,
            tags: self.configuration.tags,
            mode: self.configuration.launchMode
        )
        
        do {
            try self.httpClient.callEndPoint(endPoint) { (result: Launch) in
                self.launchID = result.id
                self.semaphore.signal()
            }
        } catch let error {
            print(error)
        }
        
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func startRootSuite(_ suite: XCTestSuite) throws {
        guard let launchID = launchID else {
            throw ReportingServiceError.launchIdNotFound
        }
        
        let endPoint = StartItemEndPoint(itemName: suite.name, launchID: launchID, type: .suite)
        try httpClient.callEndPoint(endPoint) { (result: Item) in
            self.rootSuiteID = result.id
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func startTestSuite(_ suite: XCTestSuite) throws {
        guard let launchID = launchID else {
            throw ReportingServiceError.launchIdNotFound
        }
        guard let rootSuiteID = rootSuiteID else {
            throw ReportingServiceError.launchIdNotFound
        }
        
        let endPoint = StartItemEndPoint(itemName: suite.name, parentID: rootSuiteID, launchID: launchID, type: .test)
        try httpClient.callEndPoint(endPoint) { (result: Item) in
            self.testSuiteID = result.id
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
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
        
        try httpClient.callEndPoint(endPoint) { (result: Item) in
            self.testID = result.id
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
        
        fileService.createLogFile(withName: extractTestName(from: test))
    }
    
    func reportLog(level: String, message: String) throws {
        let endPoint = PostLogEndPoint(itemID: testID, level: level, message: message)
        try httpClient.callEndPoint(endPoint) { (result: Item) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func finishTest(_ test: XCTestCase) throws {
        let testStatus = test.testRun!.hasSucceeded ? TestStatus.passed : TestStatus.failed
        if testStatus == .failed {
            testSuiteStatus = .failed
            launchStatus = .failed
        }
        
        try? reportLog(level: "info", message: fileService.readLogFile(fileName: extractTestName(from: test)))
        fileService.deleteLogFile(withName: extractTestName(from: test))
        
        let endPoint = FinishItemEndPoint(itemID: testID, status: testStatus)
        
        try httpClient.callEndPoint(endPoint) { (result: Finish) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func finishTestSuite() throws {
        guard let testSuiteID = testSuiteID else {
            throw ReportingServiceError.testSuiteIdNotFound
        }
        let endPoint = FinishItemEndPoint(itemID: testSuiteID, status: testSuiteStatus)
        try httpClient.callEndPoint(endPoint) { (result: Finish) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func finishRootSuite() throws {
        guard let rootSuiteID = rootSuiteID else {
            throw ReportingServiceError.testSuiteIdNotFound
        }
        let endPoint = FinishItemEndPoint(itemID: rootSuiteID, status: launchStatus)
        try httpClient.callEndPoint(endPoint) { (result: Finish) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
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
        try httpClient.callEndPoint(endPoint) { (result: Finish) in
            self.semaphore.signal()
        }
        _ = semaphore.wait(timeout: .now() + timeOutForRequestExpectation)
    }
    
    func getLaunchName()-> String{
        return "iOS_"+configuration.launchName+"_"+configuration.testType+"_"+configuration.environment+"_"+configuration.buildVersion
    }
}

private extension ReportingService {
    
    func extractTestName(from test: XCTestCase) -> String {
        let originName = test.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = originName.components(separatedBy: " ")
        var result = components[1].replacingOccurrences(of: "]", with: "")
        
        if configuration.testNameRules.contains(.stripTestPrefix) {
            result.removeFirst(4)
        }
        if configuration.testNameRules.contains(.whiteSpaceOnUnderscore) {
            result = result.replacingOccurrences(of: "_", with: " ")
        }
        if configuration.testNameRules.contains(.whiteSpaceOnCamelCase) {
            var insertOffset = 0
            for index in 1..<result.count {
                let currentIndex = result.index(result.startIndex, offsetBy: index + insertOffset)
                let previousIndex = result.index(result.startIndex, offsetBy: index - 1 + insertOffset)
                if String(result[previousIndex]).isLowercased && !String(result[currentIndex]).isLowercased {
                    result.insert(" ", at: currentIndex)
                    insertOffset += 1
                }
            }
        }
        
        return result
    }
    
}

extension String {
    var isLowercased: Bool {
        return lowercased() == self
    }
}
