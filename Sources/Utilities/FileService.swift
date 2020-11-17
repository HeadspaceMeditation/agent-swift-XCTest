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
  private let initialLogText = ""

  private var logDirectoryURL : URL

  init () {
    let directoryPath = fileManager.temporaryDirectory
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
  func readLogFile(fileName: String) throws -> String {
     guard fileManager.fileExists(atPath: fullLogPathForFile(with: fileName).path) else {
         throw FileServiceError.fileDoesNotExistsError
     }

     do {
       let fileContent = try String(contentsOfFile: fullLogPathForFile(with: fileName).path, encoding: String.Encoding.utf8)
       return fileContent
     } catch {
       throw FileServiceError.readFileError
     }

   }
  ///Delete file with given name
  func deleteLogFile(withName fileName: String) throws {
    guard fileManager.fileExists(atPath: fullLogPathForFile(with: fileName).path) else{
      return
    }
        
    try? fileManager.removeItem(atPath: fullLogPathForFile(with: fileName).path)
  }
    
  ///Create file with given name
  func createLogFile(withName fileName: String) {
    fileManager.createFile(atPath: fullLogPathForFile(with: fileName).path, contents: initialLogText.data(using: String.Encoding.utf8))
  }

  enum FileServiceError: Error {
    case readFileError
    case fileDoesNotExistsError
  }
}

enum FileServiceError: Error {
    case readFileError
    case fileDoesNotExistsError
}
