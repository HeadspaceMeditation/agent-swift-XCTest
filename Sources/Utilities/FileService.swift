//
//  FileService.swift
//  ReportPortalAgent
//
//  Created by Natallia Mikulskaya on 11/27/19.
//
//

import Foundation

final class FileService {
  private let fileManager = FileManager()
  private let fileExtention = ".log"
  private let logSubdirectoryName = "testLogs"
  private let initialLogText = "Test log: \r\n"
    
  private var logsDirectoryFullName : String
  private var logDirectoryURL : URL
    
  init (logsDirectory: String) {
    self.logsDirectoryFullName = logsDirectory
    ///TODO: it is a temporary solution. Instead of .documentDirectory we need to use received path from self.logDirectory.
    guard let directoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      fatalError("FileService init: Couldn't find document directory")
    }
    
    self.logDirectoryURL = directoryPath.appendingPathComponent(logSubdirectoryName)
   
    if !fileManager.fileExists(atPath: self.logDirectoryURL.path) {
      do {
        try fileManager.createDirectory(atPath: self.logDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
      } catch let error {
        print("Error creating directory: \(error.localizedDescription)")
      }
    }
  }
    
  ///Return full path for particular file with given name
  func fullLogPathForFile(with fileName: String) -> URL {
    let targetURL = self.logDirectoryURL.appendingPathComponent(fileName + fileExtention)
        
    return targetURL
  }
    
  ///Read log file with given name and return its content
  func readLogFile(fileName: String) -> String {
        
    guard fileManager.fileExists(atPath: fullLogPathForFile(with: fileName).path) else {
      return fatalError("FileService read: Couldn't find log file").localizedDescription
    }
    
    do {
      let fileContent = try String(contentsOfFile: fullLogPathForFile(with: fileName).path, encoding: String.Encoding.utf8)
      return fileContent
    } catch {
      return fatalError("FileService read: Couldn't read log file").localizedDescription
    }
        
  }
    
  ///Delete file with given name
  func deleteLogFile(withName fileName: String) {
    guard fileManager.fileExists(atPath: fullLogPathForFile(with: fileName).path) else{
      fatalError("FileService delete: Couldn't find log file")
    }
        
    try? fileManager.removeItem(atPath: fullLogPathForFile(with: fileName).path)
  }
    
  ///Create file with given name
  func createLogFile(withName fileName: String) {
    fileManager.createFile(atPath: fullLogPathForFile(with: fileName).path, contents: initialLogText.data(using: String.Encoding.utf8))
  }
}
