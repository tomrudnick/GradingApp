//
//  PDFFile.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.11.22.
//

import Foundation
import SwiftUI
import UIKit
import UniformTypeIdentifiers


enum SomeError: Error {
    case runtimeError(String)
}

struct PDFFile: FileDocument {
    
    static var readableContentTypes = [UTType.pdf]
    
    var data: Data
    var fileName: String
    
    init(fileName: String, pdfData: NSData) {
        self.fileName = fileName
        self.data = Data(referencing: pdfData)
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents, let fileName = configuration.file.filename {
            self.data = data
            self.fileName = fileName
        } else {
            throw SomeError.runtimeError("Something went wrong reading the configuration")
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.filename = fileName
        return fileWrapper
    }
    
    static func generatePDFFromExam(exam: Exam) -> PDFFile {
        let examComposer = ExamSummaryComposer(exam: exam)
        let pdfData = examComposer.renderToPDF()
        return PDFFile(fileName: exam.name, pdfData: pdfData)
    }
    
    static func generatePDFsFromExam(exam: Exam) -> [PDFFile] {
        exam.participations.filter(\.participated)
            .compactMap(\.student)
            .map {
                let examComposer = ExamStudentSummaryComposer(exam: exam, student: $0)
                let pdfData = examComposer.renderToPDF()
                return PDFFile(fileName: "\($0.lastName)_\($0.firstName)_\(exam.name)", pdfData: pdfData)
            }
    }
    
}
