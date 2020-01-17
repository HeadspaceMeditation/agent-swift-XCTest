//
//  TagHelper.swift
//  RPAgentSwiftXCTest
//
//  Created by Stas Kirichok on 23-08-2018.
//  Copyright © 2018 Windmill Smart Solutions. All rights reserved.
//

import Foundation
import UIKit

enum TagHelper {
  
   static let defaultTags = [
     ["key": "system", "system": false, "value": UIDevice.current.systemName],
     ["key": "sys_ver", "system": false, "value": UIDevice.current.systemVersion],
     ["key": "device", "system": false, "value": UIDevice.current.modelName]
   ]
  
}
