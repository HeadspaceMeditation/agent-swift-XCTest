//
//  StartItemEndPoint.swift
//  RPAgentSwiftXCTest
//
//  Created by Stas Kirichok on 23-08-2018.
//  Copyright © 2018 Windmill Smart Solutions. All rights reserved.
//

import Foundation

struct StartItemEndPoint: EndPoint {
  
  let method: HTTPMethod = .post
  var relativePath: String
  let parameters: [String : Any]
  
  init(itemName: String, parentID: String? = nil, launchID: String, type: TestType, tags: [[String: Any]] = []) {
    relativePath = "item"
    if let parentID = parentID {
      relativePath += "/\(parentID)"
    }
    
    parameters = [
     "attributes": tags,
     "codeRef": "",
     "description": "",
     "launchUuid": launchID,
     "name": itemName,
     "parameters": [],
     "retry": false,
     "startTime": TimeHelper.currentTimeAsString(),
     "testCaseHash": "",
     "testCaseId": "",
     "type": type.rawValue,
     "uniqueId": ""
    ]
  }
  
}
