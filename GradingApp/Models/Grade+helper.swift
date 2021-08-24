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
    
    private(set) static var lowerSchoolGrades = ["1+", "1", "1-",
                                                 "2+", "2", "2-",
                                                 "3+", "3", "3-",
                                                 "4+", "4", "4-",
                                                 "5+", "5", "5-",
                                                 "6"]
    
    private(set) static var gradeMultiplier = [0.5, 1.0, 1.5, 2]
    

    static func convertGradePointsToGrades(value: Int) -> String {
        return lowerSchoolGradesTranslate.first(where: {$1 == value})!.key
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
    
    func dateAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self.date!)
    }
}
