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
    
    static func compareStudents(_ s1: StudentName, _ s2: StudentName) -> Bool {
        let german = Locale(identifier: "de")
        return (s1.lastName.lowercased().compare(s2.lastName.lowercased(), locale: german) == .orderedAscending)
               || (s1.lastName.lowercased() == s2.lastName.lowercased() && s1.firstName.lowercased().compare(s2.firstName.lowercased(), locale: german) == .orderedAscending)

    }
    
    static func fetchAll() -> NSFetchRequest<Student> {
        let request = NSFetchRequest<Student>(entityName: "Student")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Student.lastName_, ascending: true)]
        return request
    }
}


