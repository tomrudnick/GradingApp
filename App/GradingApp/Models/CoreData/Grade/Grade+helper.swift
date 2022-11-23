//
//  Grade+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.08.21.
//

import Foundation
import CoreData
import SwiftUI

extension Grade {
    //setter and getter for Grade
    
    private(set) static var lowerSchoolGradesTranslate = ["1+" : 15,
                                                          "1" : 14,
                                                          "1-" : 13,
                                                          "2+" : 12,
                                                          "2" : 11,
                                                          "2-" : 10,
                                                          "3+" : 9,
                                                          "3" : 8,
                                                          "3-": 7,
                                                          "4+" : 6,
                                                          "4" : 5,
                                                          "4-" : 4,
                                                          "5+" : 3,
                                                          "5" : 2,
                                                          "5-" : 1,
                                                          "6" : 0,
                                                          "-" : -1
                                                          ]
    
    private(set) static var lowerSchoolTranscriptGrades = ["1", "2", "3", "4", "5", "6"]
    
    private(set) static var lowerSchoolGrades = ["1+", "1", "1-",
                                                 "2+", "2", "2-",
                                                 "3+", "3", "3-",
                                                 "4+", "4", "4-",
                                                 "5+", "5", "5-",
                                                 "6"]
    
    private(set) static var uppperSchoolGrades = ["15", "14", "13",
                                                 "12", "11", "10",
                                                 "9", "8", "7",
                                                 "6", "5", "4",
                                                 "3", "2", "1",
                                                 "0"]
    
    private(set) static var gradeMultiplier = [0.5, 1.0, 1.5, 2, 3, 4, 5]
    

    static func convertGradePointsToGrades(value: Int) -> String {
        return lowerSchoolGradesTranslate.first(where: {$1 == value})!.key
    }
    
    static func convertLowerGradeToPoints(grade: Int) -> Int {
        return lowerSchoolGradesTranslate[String(grade)] ?? -1
    }
    
    static func roundPoints(points: Double) -> Int {
        return Int(round(points))
    }
    
    static func convertDecimalGradesToGradePoints(points: Double) -> Double {
        return (17.0 - points) / 3.0
    }
    
    static func getColor(points: Double) -> Color {
        let points = Int(points)
        switch points {
        case 13...16:
            return Color(red: 0.173, green: 0.894, blue: 0.455)
        case 10...12:
            return Color(red: 0.803, green: 0.941, blue: 0.229)
        case 7...9:
            return Color(red: 1.0, green: 0.898, blue: 0.0)
        case 4...6:
            return Color(red: 1.0, green: 0.592, blue: 0.0)
        case 1...3:
            return Color(red: 1.0, green: 0.224, blue: 0.141)
        default:
            return Color(red: 0.737, green: 0.067, blue: 0.0)
        }
    }
    
    static func getColor(points: String) -> Color {
        if let points = Double(points) {
            return getColor(points: points)
        } else {
            return Color.white
        }
    }
    
    
    static func getGradesPerDate(grades: FetchedResults<Grade>) -> [Date : [GradeStudent<Grade>]] {
        var allDates: [Date : [GradeStudent<Grade>]] = [:]
        for grade in grades {
            if let _ = allDates[grade.date!] {
                allDates[grade.date!]!.append(GradeStudent(student: grade.student!, grade: grade))
            } else {
                allDates[grade.date!] = [GradeStudent(student: grade.student!, grade: grade)]
            }
        }
        return allDates
    }
    
    enum WrittenGradeType {
        case normal([GradeStudent<Grade>])
        case exam(Exam)
    }
    
    static func getGradesPerDate(grades: FetchedResults<Grade>, exams: FetchedResults<Exam>) -> [Date: WrittenGradeType] {
        let gradesPerDate = getGradesPerDate(grades: grades)
        var allDates: [Date: WrittenGradeType] = Dictionary(uniqueKeysWithValues: gradesPerDate.map {key, value in
            (key, WrittenGradeType.normal(value))
        })
        
        for exam in exams {
            guard allDates[exam.date] == nil else { continue }
            allDates[exam.date] = WrittenGradeType.exam(exam)
        }
        return allDates
    }
    
    static func getGradesPerDatePerMonth(grades: FetchedResults<Grade>) -> [DateComponents: [Date: [GradeStudent<Grade>]]]{
        var allDatesPerMonth: [DateComponents: [Date : [GradeStudent<Grade>]]] = [:]
        for grade in grades {
            let monthYear = Calendar.current.dateComponents([.year, .month], from: grade.date!)
            if let _ = allDatesPerMonth[monthYear] {
                if let _ = allDatesPerMonth[monthYear]![grade.date!] {
                    allDatesPerMonth[monthYear]![grade.date!]?.append(GradeStudent(student: grade.student!, grade: grade))
                } else {
                    allDatesPerMonth[monthYear]![grade.date!] = [GradeStudent(student: grade.student!, grade: grade)]
                }
            } else {
                allDatesPerMonth[monthYear] = [grade.date! : [GradeStudent(student: grade.student!, grade: grade)]]
            }
        }
        return allDatesPerMonth
    }
    
    static func getGradesPerDate(grades: [Grade]) -> [Date : [GradeStudent<Grade>]] {
        var allDates: [Date : [GradeStudent<Grade>]] = [:]
        for grade in grades {
            if let _ = allDates[grade.date!] {
                allDates[grade.date!]!.append(GradeStudent(student: grade.student!, grade: grade))
            } else {
                allDates[grade.date!] = [GradeStudent(student: grade.student!, grade: grade)]
            }
        }
        return allDates
    }
}


extension Grade {
    convenience init(value: Int, date: Date, half: HalfType, type: GradeType, comment: String, multiplier: Double, student: Student,
                     context: NSManagedObjectContext) {
        self.init(context: context)
        self.value = Int32(value)
        self.date = date
        self.type = type
        self.comment = comment
        self.half = half
        self.multiplier = multiplier
        self.student = student
    }
    
    
    static func addGrade(value: Int, date: Date, half: HalfType, type: GradeType, comment: String, multiplier: Double, student: Student, context: NSManagedObjectContext) {
        _ = Grade(value: value, date: date, half: half, type: type, comment: comment, multiplier: multiplier, student: student, context: context)
        context.saveCustom()
    }
    
    static func delete(at offset: IndexSet, for grades: [Grade]) {
        if let first = grades.first, let viewContext = first.managedObjectContext {
            offset.map{ grades[$0] }.forEach(viewContext.delete)
        }
    }
    
    func delete() {
        if let viewContext = self.managedObjectContext {
            viewContext.delete(self)
        }
    }
    
    func dateAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self.date!)
    }
    
    func getColor() -> Color {
        Grade.getColor(points: Double(self.value))
    }
    
    func toString() -> String {
        Grade.toString(ageGroup: self.student?.course?.ageGroup, value: value)
    }
    
    static func toString(ageGroup: AgeGroup?, value: Int32) -> String {
        switch ageGroup {
        case .lower:
            return Grade.convertGradePointsToGrades(value: Int(value))
        case .upper:
            return String(value)
        case .none:
            return ""
        }
    }
    
    static func getComment(studentGrades: [GradeStudent<Grade>]) -> String? {
        let nonNilStudentGrades = studentGrades.filter{ $0.grade != nil }
        let comments = nonNilStudentGrades.map{ $0.grade!.comment! }
        if let comment = comments.first, comments.allSatisfy({$0 == comment}) {
            return comment
        } else {
            return nil
        }
    }
    
    static func fetch(_ predicate: NSPredicate) -> NSFetchRequest<Grade> {
        let request = NSFetchRequest<Grade>(entityName: "Grade")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = predicate
        return request
    }
    
    static func fetchAll() -> NSFetchRequest<Grade> {
        let request = NSFetchRequest<Grade>(entityName: "Grade")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return request
    }
}
