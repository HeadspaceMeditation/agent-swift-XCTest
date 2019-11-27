//
//  FileService.swift
//  ReportPortalAgent
//
//  Created by Natallia Mikulskaya on 11/27/19.
//
//

import Foundation

class FileService {
  private let fileManager = FileManager()
  private let fileExtention = ".log"
  private let logSubdirectoryName = "testLogs"
    
  private var logsDirectoryFullName : String
  private var logDirectoryURL : URL?
    
  init (logsDirectory: String ){
    self.logsDirectoryFullName = logsDirectory
    ///TODO: it is a temporary solution. Instead of .documentDirectory we need to use received path from self.logDirectory.
    self.logDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(logSubdirectoryName)
        
     if !fileManager.fileExists(atPath: self.logDirectoryURL!.path){
       do{
         try fileManager.createDirectory(atPath: self.logDirectoryURL!.path, withIntermediateDirectories: true, attributes: nil)
       }
       catch let error {
         print("Error creating directory: \(error.localizedDescription)")
       }
    }
  }
    
  ///Return full path for particular file with given name
  func getFullLogFilePath(forFile fileName: String) -> URL {
    let targetURL = self.logDirectoryURL!.appendingPathComponent(fileName+fileExtention)
        
    return targetURL
  }
    
  ///Read log file with given name and return its content
  func readLogFile(fileName: String) -> String {
        
    guard fileManager.fileExists(atPath: getFullLogFilePath(forFile: fileName).path) else{
      return "No log file was found"
    }
    
    do {
      let fileContent = try String(contentsOfFile: getFullLogFilePath(forFile: fileName).path, encoding: String.Encoding.utf8)
      return fileContent
    } catch {
      return "Can't get data from log file with name: \(fileName+fileExtention)"
    }
        
  }
    
  ///Delete file with given name
  func deleteLogFile(withName fileName: String) {
    guard fileManager.fileExists(atPath: getFullLogFilePath(forFile: fileName).path) else{
      return
    }
        
    try? fileManager.removeItem(atPath: getFullLogFilePath(forFile: fileName).path)
  }
    
  ///Create file with given name
  func createLogFile(withName fileName: String) {
    let emptyString = "Test log: 4430945304958034958035"
        
    fileManager.createFile(atPath: getFullLogFilePath(forFile: fileName).path, contents: emptyString.data(using: String.Encoding.utf8))
  }
}
