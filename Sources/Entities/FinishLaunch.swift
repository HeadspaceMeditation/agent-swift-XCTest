//
//  FinishLaunch.swift
//  RPAgentSwiftXCTest
//
//  Created by Natallia Mikuslakaya on 21-01-2020.
//

import Foundation

enum FinishLaunchKeys: String, CodingKey {
  case launchId = "msg"
}

struct FinishLaunch: Decodable {
  let launchId: String

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: FinishLaunchKeys.self)
    launchId = try container.decode(String.self, forKey: .launchId)
  }
}
