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
}


extension Student {
    convenience init(firstName: String, lastName: String, email: String, hidden: Bool = false, course: Course, context: NSManagedObjectContext) {
        self.init(context: context)
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.hidden = hidden
        self.course = course
    }
    
    static func addStudent(firstName: String, lastName: String, email: String, hidden: Bool = false, course: Course, context: NSManagedObjectContext) {
        _ = Student(firstName: firstName, lastName: lastName, email: email, hidden: hidden, course: course, context: context)
        context.saveCustom()
    }
    static func addStudent(student: DataModel,course: Course, context: NSManagedObjectContext){
        addStudent(firstName: student.firstName, lastName: student.lastName, email: student.email, hidden: student.hidden, course: course, context: context)
    }
}


