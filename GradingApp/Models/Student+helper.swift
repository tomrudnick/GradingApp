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
    
    func gradeAverage(type: GradeType) -> Double {
        let filteredGrades = grades.filter { $0.type == type }
        if filteredGrades.count == 0 {
            return 0.0
        }
        let sum = filteredGrades.reduce(0) { result, grade in
            result + Double(grade.value) * grade.multiplier
        }
        return Double(sum) / Double(filteredGrades.count)
    }
    
    func gradeAverage() -> Double {
        return (gradeAverage(type: .oral) + gradeAverage(type: .written)) / 2.0
    }
    
    func getLowerSchoolRoundedGradeAverage(_ type: GradeType) -> String {
        return Grade.gradeValueToLowerSchool(value: Grade.roundPoints(points: gradeAverage(type: type)))
    }
    
    func getLowerSchoolRoundedGradeAverage() -> String {
        return Grade.gradeValueToLowerSchool(value: Grade.roundPoints(points: gradeAverage()))
    }
    
    func getLowerSchoolGradeAverage(_ type: GradeType) -> String {
        return String(format: "%.2f", Grade.convertToLowerSchoolGrade(points: gradeAverage(type: type)))
    }
    
    func getLowerSchoolGradeAverage() -> String {
        return String(format: "%.2f", Grade.convertToLowerSchoolGrade(points: gradeAverage()))
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
        do {
            try context.save()
        } catch {
            let error = error as NSError
            fatalError("Uresolved Problem when creating a Student: \(error)")
        }
    }
}

