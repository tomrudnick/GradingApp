//
//  Grade+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.08.21.
//

import Foundation
import CoreData

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
    

    static func gradeValueToLowerSchool(value: Int) -> String {
        return lowerSchoolGradesTranslate.first(where: {$1 == value})!.key
    }
    
    static func roundPoints(points: Double) -> Int {
        return Int(round(points))
    }
    
    static func convertToLowerSchoolGrade(points: Double) -> Double {
        return (17.0 - points) / 3.0
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
    
    func dateAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self.date!)
    }
}
