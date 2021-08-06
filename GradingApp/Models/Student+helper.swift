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
    
}

extension Student {
    static func addStudent(firstName: String, lastName: String, email: String, course: Course, context: NSManagedObjectContext) {
        let newStudent = Student(context: context)
        newStudent.course = course
        newStudent.firstName = firstName
        newStudent.lastName = lastName
        newStudent.email = email
        do {
            try context.save()
        } catch {
            let error = error as NSError
            fatalError("Uresolved Problem when creating a Student: \(error)")
        }
    }
    
    
}
