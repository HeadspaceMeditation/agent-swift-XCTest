//
//  RPConstants.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Windmill Smart Solutions on 7/5/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import Foundation
import UIKit

public extension UIDevice {
    
    public var modelName: String {
      var model = ""
      var postfix = ""
      var systemInfo = utsname()
      uname(&systemInfo)
      let machineMirror = Mirror(reflecting: systemInfo.machine)
      var identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
      }
      if identifier == "i386" || identifier == "x86_64" {
        identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "unknown"
        postfix = " (simulator)"
      }
        
    switch identifier {
    case "iPod5,1":                                 model = "iPod Touch 5\(postfix)"
    case "iPod7,1":                                 model = "iPod Touch 6\(postfix)"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     model = "iPhone 4\(postfix)"
    case "iPhone4,1":                               model = "iPhone 4s\(postfix)"
    case "iPhone5,1", "iPhone5,2":                  model = "iPhone 5\(postfix)"
    case "iPhone5,3", "iPhone5,4":                  model = "iPhone 5c\(postfix)"
    case "iPhone6,1", "iPhone6,2":                  model = "iPhone 5s\(postfix)"
    case "iPhone7,2":                               model = "iPhone 6\(postfix)"
    case "iPhone7,1":                               model = "iPhone 6 Plus\(postfix)"
    case "iPhone8,1":                               model = "iPhone 6s\(postfix)"
    case "iPhone8,2":                               model = "iPhone 6s Plus\(postfix)"
    case "iPhone9,1", "iPhone9,3":                  model = "iPhone 7\(postfix)"
    case "iPhone9,2", "iPhone9,4":                  model = "iPhone 7 Plus\(postfix)"
    case "iPhone10,1", "iPhone10,4":                model = "iPhone 8\(postfix)"
    case "iPhone10,2", "iPhone10,5":                model = "iPhone 8 Plus\(postfix)"
    case "iPhone10,3":                              model = "iPhone X\(postfix)"
    case "iPhone10,6":                              model = "iPhone X GSM\(postfix)"
    case "iPhone11,2":                              model = "iPhone XS\(postfix)"
    case "iPhone11,4":                              model = "iPhone XS Max\(postfix)"
    case "iPhone11,6":                              model = "iPhone XS Max Global\(postfix)"
    case "iPhone11,8":                              model = "iPhone XR\(postfix)"
    case "iPhone12,1":                              model = "iPhone 11\(postfix)"
    case "iPhone12,3":                              model = "iPhone 11 Pro\(postfix)"
    case "iPhone12,5":                              model = "iPhone 11 Pro Max\(postfix)"
    case "iPhone8,4":                               model = "iPhone SE (GSM)\(postfix)"
        
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":model = "iPad 2\(postfix)"
    case "iPad3,1", "iPad3,2", "iPad3,3":           model = "iPad 3\(postfix)"
    case "iPad3,4", "iPad3,5", "iPad3,6":           model = "iPad 4\(postfix)"
    case "iPad4,1", "iPad4,2", "iPad4,3":           model = "iPad Air\(postfix)"
    case "iPad5,3", "iPad5,4":                      model = "iPad Air 2\(postfix)"
    case "iPad2,5", "iPad2,6", "iPad2,7":           model = "iPad Mini\(postfix)"
    case "iPad4,4", "iPad4,5", "iPad4,6":           model = "iPad Mini 2\(postfix)"
    case "iPad4,7", "iPad4,8", "iPad4,9":           model = "iPad Mini 3\(postfix)"
    case "iPad5,1", "iPad5,2":                      model = "iPad Mini 4\(postfix)"
    case "iPad6,3", "iPad6,4":                      model = "iPad Pro 9.7\"\(postfix)"
    case "iPad6,7", "iPad6,8":                      model = "iPad Pro 12.9\"\(postfix)"
    case "iPad7,1", "iPad7,2":                      model = "iPad Pro 2 12.9\"\(postfix)"
    case "iPad7,3", "iPad7,4":                      model = "iPad Pro 10.5\"\(postfix)"
    case "iPad7,5":                                 model = "iPad 6th Gen (WiFi)\"\(postfix)"
    case "iPad7,6":                                 model = "iPad 6th Gen (WiFi+Cellular)\"\(postfix)"
    case "iPad7,11":                                model = "iPad 7th Gen 10.2-inch (WiFi)\"\(postfix)"
    case "iPad7,12":                                model = "iPad 7th Gen 10.2-inch (WiFi+Cellular)\"\(postfix)"
    case "iPad8,1":                                 model = "iPad Pro 3rd Gen (11 inch, WiFi)\"\(postfix)"
    case "iPad8,2":                                 model = "iPad Pro 3rd Gen (11 inch, 1TB, WiFi)\"\(postfix)"
    case "iPad8,3":                                 model = "iPad Pro 3rd Gen (11 inch, WiFi+Cellular)\"\(postfix)"
    case "iPad8,4":                                 model = "iPad Pro 3rd Gen (11 inch, 1TB, WiFi+Cellular)\"\(postfix)"
    case "iPad8,5":                                 model = "iPad Pro 3rd Gen (12.9 inch, WiFi)\"\(postfix)"
    case "iPad8,6":                                 model = "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)\"\(postfix)"
    case "iPad8,7":                                 model = "iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)\"\(postfix)"
    case "iPad8,8":                                 model = "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)\"\(postfix)"
    case "iPad11,1":                                model = "iPad mini 5th Gen (WiFi)\"\(postfix)"
    case "iPad11,2":                                model = "iPad mini 5th Gen\"\(postfix)"
    case "iPad11,3":                                model = "iPad Air 3rd Gen (WiFi)\"\(postfix)"
    case "iPad11,4":                                model = "iPad Air 3rd Gen\"\(postfix)"
        
    case "AppleTV2,1":                              model = "Apple TV 2\(postfix)"
    case "AppleTV3,1", "AppleTV3,2":                model = "Apple TV 3\(postfix)"
    case "AppleTV5,3":                              model = "Apple TV 4\(postfix)"
    case "AppleTV6,2":                              model = "Apple TV 4K\(postfix)"
        
    case "Watch1,1":                                model = "Apple Watch 38mm case\(postfix)"
    case "Watch1,2":                                model = "Apple Watch 42mm case\(postfix)"
    case "Watch2,6":                                model = "Apple Watch Series 1 38mm case\(postfix)"
    case "Watch2,7":                                model = "Apple Watch Series 1 42mm case\(postfix)"
    case "Watch2,3":                                model = "Apple Watch Series 2 38mm case\(postfix)"
    case "Watch2,4":                                model = "Apple Watch Series 2 42mm case\(postfix)"
    case "Watch3,1":                                model = "Apple Watch Series 3 38mm case (GPS+Cellular)\(postfix)"
    case "Watch3,2":                                model = "Apple Watch Series 3 42mm case (GPS+Cellular)\(postfix)"
    case "Watch3,3":                                model = "Apple Watch Series 3 38mm case\(postfix)"
    case "Watch3,4":                                model = "Apple Watch Series 3 42mm case\(postfix)"
    case "Watch4,1":                                model = "Apple Watch Series 4 40mm case (GPS)\(postfix)"
    case "Watch4,2":                                model = "Apple Watch Series 4 44mm case (GPS)\(postfix)"
    case "Watch4,3":                                model = "Apple Watch Series 4 40mm case (GPS+Cellular)\(postfix)"
    case "Watch4,4":                                model = "Apple Watch Series 4 44mm case (GPS+Cellular)\(postfix)"
    case "Watch5,1":                                model = "Apple Watch Series 5 40mm case (GPS)\(postfix)"
    case "Watch5,2":                                model = "Apple Watch Series 5 44mm case (GPS)\(postfix)"
    case "Watch5,3":                                model = "Apple Watch Series 5 40mm case (GPS+Cellular)\(postfix)"
    case "Watch5,4":                                model = "Apple Watch Series 5 44mm case (GPS+Cellular)\(postfix)"
    default:                                        model = identifier
    }
    return model
  }
    
}
