//
//  Course+CSV.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import CSV


struct CSVFile: FileDocument {
    // tell the system we support only csv text
    static var readableContentTypes = [UTType.commaSeparatedText]


    private let fileName: String
    private let data: String

    init(course: Course, grades: [Grade], fileName: String) {
        self.fileName = fileName
        let csv = try! CSVWriter(stream: OutputStream.toMemory())
        let studentGrades = Grade.getGradesPerDate(grades: grades)
        try! csv.write(row: ["Kurs", "Vorname", "Nachname", "Email"])
        for (key, _) in studentGrades.sorted(by: {$0.key < $1.key}) {
            try! csv.write(field: key.asString(format: "dd MMM"))
        }
        
        for student in course.studentsArr {
            csv.beginNewRow()
            try! csv.write(field: course.name)
            try! csv.write(field: student.firstName)
            try! csv.write(field: student.lastName)
            try! csv.write(field: student.email)
            let dates = studentGrades.map { date, _ in date }.sorted(by: {$0 < $1})
            for date in dates {
                if let grade = studentGrades[date]?.first(where: {$0.student == student}) {
                    try! csv.write(field: String(grade.value))
                } else {
                    try! csv.write(field: "")
                }
            }
        }
        self.data = String(data: csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data, encoding: .utf8)!
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

    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(self.data.utf8)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.filename = fileName
        return fileWrapper
    }
}
