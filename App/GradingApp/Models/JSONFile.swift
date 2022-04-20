//
//  JSONFile.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 04.09.21.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers




struct JSONFile: FileDocument {
    
    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(self.data.utf8)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.filename = fileName
        return fileWrapper
    }
    
    // tell the system we support only plain text files
    static var readableContentTypes = [UTType.json]
    
    private let fileName: String
    private let data: String
    
    init(data: String, fileName: String) {
        self.data = data
        self.fileName = fileName
    }
    
    // this initializer loads data that has been saved previously
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents, let fileName = configuration.file.filename {
            self.data = String(decoding: data, as: UTF8.self)
            self.fileName = fileName
        } else {
            self.data = ""
            self.fileName = "UNKOWN"
        }
    }
    
    static func generateJSONBackupFile(jsonData: String) ->  JSONFile {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_YYYY"
        let fileDate = dateFormatter.string(from: date)
        return JSONFile(data: jsonData, fileName: "Backup_" + fileDate)
    }
    
}
