//
//  EndPoint.swift
//  com.oxagile.automation.RPAgentSwiftXCTest
//
//  Created by Windmill Smart Solutions on 8/29/17.
//  Copyright © 2017 Oxagile. All rights reserved.
//

import  UIKit

enum ParameterEncoding {
  case url
  case json
  case multipart
}

enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
}

protocol EndPoint {
  
  var headers: [String: String] { get }
  var encoding: ParameterEncoding { get }
  var method: HTTPMethod { get }
  var relativePath: String { get }
  var parameters: [String: Any] { get }
  var fileName: String { get }
  var imageContent: UIImage { get }
  
}

extension EndPoint {
  
  var headers: [String: String] { return [:] }
  var encoding: ParameterEncoding { return .json }
  var method: HTTPMethod { return .get }
  var parameters: [String: Any] { return [:] }
  var fileName : String { return "" }
  var imageContent: UIImage { return UIImage() }
}
