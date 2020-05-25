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

  init(itemID: String, status: TestStatus, tags: [[String: Any]] = []) {
    relativePath = "item/\(itemID)"
    parameters = [
      "attributes": tags,
      "description": "",
      "endTime": TimeHelper.currentTimeAsString(),
      "issue": [
        "autoAnalyzed": "false",
        "comment": "",
        "externalSystemIssues": [],
        "ignoreAnalyser": false,
        "issueType": status == .failed ? "ti001" : "nd001"
      ],
      "launchUuid": "",
      "retry": false,
      "status": status.rawValue
    ]
  }

}
