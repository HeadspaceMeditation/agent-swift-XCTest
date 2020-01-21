//
//  FinishItemEndPoint.swift
//  RPAgentSwiftXCTest
//
//  Created by Stas Kirichok on 23-08-2018.
//  Copyright © 2018 Windmill Smart Solutions. All rights reserved.
//

import Foundation

struct FinishItemEndPoint: EndPoint {
  
  let method: HTTPMethod = .put
  let relativePath: String
  let parameters: [String : Any]
  
  init(itemID: String, status: TestStatus) {
    relativePath = "item/\(itemID)"
    parameters = [
      "attributes": [],
      "description": "",
      "endTime": TimeHelper.currentTimeAsString(),
      "issue": [
        "autoAnalyzed": "false",
        "comment": "",
        "externalSystemIssues": [],
        "ignoreAnalyser": true,
        "issueType": status == .failed ? "ti001" : "nd001"
      ],
      "launchUuid": "",
      "retry": false,
      "status": status.rawValue
    ]
  }
  
}
