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
                                                          "6" : 0
                                                          ]
    
    private(set) static var lowerSchoolGrades = ["1+", "1", "1-",
                                                 "2+", "2", "2-",
                                                 "3+", "3", "3-",
                                                 "4+", "4", "4-",
                                                 "5+", "5", "5-",
                                                 "6"]
    
    private(set) static var gradeMultiplier = [0.5, 0.75, 1.0, 1.25, 1.5]
    

    static func gradeValueToLowerSchool(value: Int) -> String {
        return lowerSchoolGradesTranslate.first(where: {$1 == value})!.key
    }
    
    static func roundPoints(points: Double) -> Int {
        return Int(round(points))
    }
    
    static func convertToLowerSchoolGrade(points: Double) -> Double {
        return (17.0 - points) / 3.0
    }
    
    
    
    static func addGrade(value: Int, date: Date, half: HalfType, type: GradeType, comment: String, multiplier: Double, student: Student, context: NSManagedObjectContext) {
        let grade = Grade(context: context)
        grade.value = Int32(value)
        grade.date = date
        grade.type = type
        grade.comment = comment
        grade.half = half
        grade.multiplier = multiplier
        grade.student = student
        print("Add Grade with Value:  \(grade.value)")
        do {
            try context.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Problem when creating a Course: \(error)")
        }
    }
}
