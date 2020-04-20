//
//  PostScreenshotEndPoint.swift
//  ReportPortalAgent
//
//  Created by EPAM Contractor  on 4/20/20.
//  Copyright © 2020 Sergey Komarov. All rights reserved.
//

import Foundation

struct PostScreenshotEndPoint: EndPoint {

  let method: HTTPMethod = .post
  let relativePath: String = "log"
  let parameters: [String : Any]

  init(itemID: String, fileName: String) {
    parameters = [
      "file" : ["name": fileName],
      "item_id": itemID,
      "time": TimeHelper.currentTimeAsString()
    ]
  }
}

