//
//  PostScreenshotEndPoint.swift
//  ReportPortalAgent
//
//  Created by EPAM Contractor  on 4/20/20.
//  Copyright © 2020 Sergey Komarov. All rights reserved.
//

import Foundation
import UIKit

struct PostScreenshotEndPoint: EndPoint {

  let method: HTTPMethod = .post
  let relativePath: String = "log"
  let parameters: [String : Any]
  let encoding: ParameterEncoding = .multipart
  let fileName: String
  let imageContent: UIImage

  init(itemID: String, fileName: String, content: UIImage, message: String) {
    parameters = [
      "file" : ["name": fileName],
      "item_id": itemID,
      "level": "error",
      "message": message,
      "time": TimeHelper.currentTimeAsString()
    ]
    self.imageContent = content
    self.fileName = fileName
  }
}

