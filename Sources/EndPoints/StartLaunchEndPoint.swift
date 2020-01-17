//
//  StartLaunchEndPoint.swift
//  RPAgentSwiftXCTest
//
//  Created by Stas Kirichok on 23-08-2018.
//  Copyright © 2018 Windmill Smart Solutions. All rights reserved.
//

import Foundation

struct StartLaunchEndPoint: EndPoint {
  
  let method: HTTPMethod = .post
  let relativePath: String = "launch"
  let parameters: [String : Any]
  
  init(launchName: String, tags: [[String : Any]], mode: LaunchMode) {
    parameters = [
      "attributes": tags,
      "description": "",
      "mode": mode.rawValue,
      "name": launchName,
      "rerun": false,
      "rerunOf": "",
      "startTime": TimeHelper.currentTimeAsString()
    ]
  }
  
}
