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
    
    // this will be called when the system wants to write our data to disk
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(self.data.utf8)
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.filename = fileName
        return fileWrapper
    }
    
    static func generateCSVFileOFCourse(course: Course, grades: [Grade], fileName: String) -> CSVFile {
        let csv = try! CSVWriter(stream: OutputStream.toMemory())
        let studentGrades = Grade.getGradesPerDate(grades: grades)
        
        // CSV - HEADER ROW START
        try! csv.write(row: ["Kurs", "Vorname", "Nachname", "Email"])
        for (key, _) in studentGrades.sorted(by: {$0.key < $1.key}) {
            try! csv.write(field: key.asString(format: "dd MMM"))
        }
        // CSV - HEADER ROW END
        
        
        //Grade Comments
        csv.beginNewRow()
        try! csv.write(row: ["Kommentar","","",""])
        for (_, value) in studentGrades.sorted(by: {$0.key < $1.key }) {
            let nonNilStudentGrades = value.filter{ $0.grade != nil }
            let comments = nonNilStudentGrades.map{ $0.grade!.comment! }
            if let comment = comments.first, comments.allSatisfy({$0 == comment}) {
                try! csv.write(field: comment)
            } else {
                try! csv.write(field: "")
            }
        }
        
        
        //STUDENT Grades
        for student in course.studentsArr {
            csv.beginNewRow()
            try! csv.write(field: course.title)
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
        let data = String(data: csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data, encoding: .utf8)!
        return CSVFile(data: data, fileName: fileName)
    }
    
    static func generateCSVCourseData(courses: [Course]) ->  CSVFile {
        let csv = try! CSVWriter(stream: OutputStream.toMemory())
        for course in courses {
            let studentsOfCourse = course.studentsArr
            var studentGradesOfCourse: [Grade] = []
            for student in studentsOfCourse {
                studentGradesOfCourse = studentGradesOfCourse + student.gradesArr
            }
            let studentGrades = Grade.getGradesPerDate(grades: studentGradesOfCourse)
            
            // CSV - HEADER ROW START
            try! csv.write(row: ["BEGIN \(course.title)"])
            try! csv.write(row: ["Kurs", "Vorname", "Nachname", "Email"])
            for (key, _) in studentGrades.sorted(by: {$0.key < $1.key}) {
                try! csv.write(field: key.asString(format: "YYYY-MM-dd_HH:MM:SS"))
            }
            // CSV - HEADER ROW END
            
            
            //Grade Comments
            csv.beginNewRow()
            try! csv.write(row: ["Kommentar","","",""])
            for (_, value) in studentGrades.sorted(by: {$0.key < $1.key }) {
                let nonNilStudentGrades = value.filter{ $0.grade != nil }
                let comments = nonNilStudentGrades.map{ $0.grade!.comment! }
                if let comment = comments.first, comments.allSatisfy({$0 == comment}) {
                    try! csv.write(field: comment)
                } else {
                    try! csv.write(field: "")
                }
            }
            
    
            //STUDENT Grades
            for student in course.studentsArr {
                csv.beginNewRow()
                try! csv.write(field: course.title)
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
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_YYYY"
        let fileDate = dateFormatter.string(from: date)
        let data = String(data: csv.stream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data, encoding: .utf8)!
        return CSVFile(data: data, fileName: "Backup_" + fileDate)
    }
}
