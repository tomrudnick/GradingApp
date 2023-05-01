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
import PDFKit


enum SomeError: Error {
    case runtimeError(String)
}

enum ImportError: Error {
    case countMissmatch
    case matchInsecurity( [(student: Student, fileName: String, score: Double)], [Student : PDFFile] )
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
        return PDFFile(fileName: "\(exam.name)_\(exam.course?.name ?? "")_Rudnick_Schulleitung", pdfData: pdfData)
    }
    
    static func generatePDFsFromExam(exam: Exam) -> [PDFFile] {
        exam.participations
            .filter(\.participated)
            .compactMap(\.student)
            .map {
                let examComposer = ExamStudentSummaryComposer(exam: exam, student: $0)
                let pdfData = examComposer.renderToPDF()
                return PDFFile(fileName: "\($0.lastName)_\($0.firstName)_\(exam.name)", pdfData: pdfData)
            }
    }
    
    static func generatePDFFromExam(exam: Exam, student: Student) -> PDFFile {
        let examComposer = ExamStudentSummaryComposer(exam: exam, student: student)
        let pdfData = examComposer.renderToPDF()
        return PDFFile(fileName: "\(student.lastName)_\(student.firstName)_\(exam.name)", pdfData: pdfData)
    }
    
    static func mergePdf(data: Data, otherPdfDocument: PDFDocument, fileName: String) -> PDFFile {
        // get the pdfData
        let pdfDocument = PDFDocument(data: data)!
     
        // create new PDFDocument
        let newPdfDocument = PDFDocument()

        // insert all pages of first document
        for p in 0..<pdfDocument.pageCount {
            let page = pdfDocument.page(at: p)!
            let copiedPage = page.copy() as! PDFPage // from docs
            newPdfDocument.insert(copiedPage, at: newPdfDocument.pageCount)
        }

        // insert all pages of other document
        for q in 0..<otherPdfDocument.pageCount {
            let page = otherPdfDocument.page(at: q)!
            let copiedPage = page.copy() as! PDFPage
            newPdfDocument.insert(copiedPage, at: newPdfDocument.pageCount)
        }
        guard let pdfData = newPdfDocument.dataRepresentation() as? NSData else { fatalError("Data Represenation not available") }
        return PDFFile(fileName: fileName, pdfData: pdfData)
    }
    
    static func pdfFileExamImporter(exam: Exam, result: Result<[URL], Error>) throws -> [Student: PDFFile] {
        let selectedFiles = try result.get()
        let students = exam.participations.filter(\.participated).compactMap(\.student)
        if selectedFiles.count != students.count {
            throw ImportError.countMissmatch
        }
        
        let fileNames = selectedFiles.map(\.lastPathComponent)
        var exportedExams: [Student: PDFFile] = [:]
        var possibleMissmatches: [(student: Student, fileName: String, score: Double)] = []
        for student in students {
            let studentName = "\(student.lastName)_\(student.firstName)"
            let scores = fileNames.map { (fileName: $0, score: $0.fuzzyMatchPattern(studentName)) }
                .compactMap { $0.score != nil ? (fileName: $0.fileName, score: $0.score!) : nil }
            
            let confidenceLevels = scores.map { (fileName: $0.fileName, score: $0.fileName.confidenceScore(studentName) ?? Double.greatestFiniteMagnitude) }
            let minScore = confidenceLevels.reduce((fileName: "", score: Double.greatestFiniteMagnitude), {
                return $0.score < $1.score ? $0 : $1
            })
            
            let examSummary = PDFFile.generatePDFFromExam(exam: exam, student: student)
            guard let file = selectedFiles.first(where: { $0.lastPathComponent ==  minScore.fileName }) else { continue }
            guard file.startAccessingSecurityScopedResource() else { continue }
            
            guard let examPDFDocument = PDFDocument(url: file) else { continue }
            let fileName = "\(studentName)_\(exam.name)_\(exam.course?.name ?? "")_benotet"
            let mergedFile = PDFFile.mergePdf(data: examSummary.data, otherPdfDocument: examPDFDocument, fileName: fileName)
            exportedExams[student] = mergedFile
            
            file.stopAccessingSecurityScopedResource()
            
            if minScore.score >= 0.5 {
                possibleMissmatches.append((student: student, fileName: minScore.fileName, score: minScore.score))
            }
        
        }
        if possibleMissmatches.count > 0 {
            throw ImportError.matchInsecurity(possibleMissmatches,exportedExams)
        }
        
        return exportedExams
    }
    
}
