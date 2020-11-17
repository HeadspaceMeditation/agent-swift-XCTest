//
//  Finish.swift
//  RPAgentSwiftXCTest
//
//  Created by Stas Kirichok on 23-08-2018.
//  Copyright © 2018 Windmill Smart Solutions. All rights reserved.
//

import Foundation

enum FinishItemKeys: String, CodingKey {
  case msg = "message"
}


struct FinishItem: Decodable {
  let message: String

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: FinishItemKeys.self)
    message = try container.decode(String.self, forKey: .msg)
  }
}
