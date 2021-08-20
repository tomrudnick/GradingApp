//
//  Student.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import Foundation
import CoreData

extension Student {
    var firstName : String {
        get { firstName_ ?? ""}
        set { firstName_ = newValue}
    }
    
    var lastName : String {
        get { lastName_ ?? ""}
        set { lastName_ = newValue}
    }
    
    var email : String {
        get { email_ ?? ""}
        set { email_ = newValue}
    }
    
    var grades : Set<Grade> {
        get { grades_ as? Set<Grade> ?? [] }
        set { grades_ = newValue as NSSet }
    }
    
    var gradesArr : Array<Grade> {
        get { grades.sorted {$0.date! < $1.date! } }
    }
    
    func gradesExist (_ type: GradeType) -> Bool {
        let filteredGrades = grades.filter { $0.type == type }
        if filteredGrades.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    func gradesExist () -> Bool {
        if grades.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    
    func gradeAverage(type: GradeType) -> Double {
        let filteredGrades = grades.filter { $0.type == type }
        if filteredGrades.count == 0 {
            return -1
        }
        let sum = filteredGrades.reduce(0) { result, grade in
            result + Double(grade.value) * grade.multiplier
        }
        return Double(sum) / Double(filteredGrades.count)
    }
    
    
    
    func totalGradeAverage() -> Double {
        if gradesExist(.oral) && gradesExist(.written) {
            return (gradeAverage(type: .oral) + gradeAverage(type: .written)) / 2.0
        } else if gradesExist(.oral) && !gradesExist(.written) {
            return gradeAverage(type: .oral)
        } else if !gradesExist(.oral) && gradesExist(.written) {
            return gradeAverage(type: .written)
        } else {
            return -1
        }
    }
    
    func getLowerSchoolRoundedGradeAverage(_ type: GradeType) -> String {
        if gradesExist(type) {
            return Grade.convertGradePointsToGrades(value: Grade.roundPoints(points: gradeAverage(type: type)))
        } else {
            return "-"
        }
    }
    
    func getLowerSchoolRoundedGradeAverage() -> String {
        if gradesExist() {
            return Grade.convertGradePointsToGrades(value: Grade.roundPoints(points: totalGradeAverage()))
        } else {
            return "-"
        }
    }
    
    func getLowerSchoolGradeAverage(_ type: GradeType) -> String {
        if gradesExist(type) {
            return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: gradeAverage(type: type)))
        } else {
            return "-"
        }
    }
    
    func getLowerSchoolGradeAverage() -> String {
        if gradesExist() {
            return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: totalGradeAverage()))
        } else {
            return "-"
        }
    }
    
    
    
}

extension Student {
    convenience init(firstName: String, lastName: String, email: String, course: Course, context: NSManagedObjectContext) {
        self.init(context: context)
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.course = course
    }
    
    static func addStudent(firstName: String, lastName: String, email: String, course: Course, context: NSManagedObjectContext) {
        _ = Student(firstName: firstName, lastName: lastName, email: email, course: course, context: context)
        context.saveCustom()
    }
}

