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
  
  init(itemName: String, parentID: String? = nil, launchID: String, type: TestType) {
    relativePath = "item"
    if let parentID = parentID {
      relativePath += "/\(parentID)"
    }
    
    parameters = [
      "attributes": ["key" : "", "system" : false, "value" : ""],
      "codeRef": "",
      "description": "",
      "hasStats": false,
      "launchUuid": launchID,
      "name": itemName,
      "parameters": ["key": "", "value": ""],
      "retrey": false,
      "startTime": TimeHelper.currentTimeAsString(),
      "testCaseHash": 0,
      "type": type.rawValue,
      "uniqueIu": ""
    ]
  }
  
}
