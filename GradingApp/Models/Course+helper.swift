//
//  Course.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import Foundation
import CoreData

extension Course {
    
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue}
    }
    
    var students: Set<Student> {
        get { students_ as? Set<Student> ?? [] }
        set { students_ = newValue as NSSet}
    }
    
    var studentsArr: Array<Student> {
        get { students.sorted { $0.lastName < $1.lastName } }
    }
}


extension Course {
    static func addCourse(courseName: String, context: NSManagedObjectContext) {
        let newCourse = Course(context: context)
        newCourse.name = courseName
        do {
            try context.save()
        } catch {
            let error = error as NSError
            fatalError("Uresolved Problem when creating a Course: \(error)")
        }
    }
    
    
    static func fetchAll() -> NSFetchRequest<Course> {
        let request = NSFetchRequest<Course>(entityName: "Course")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Course.name_, ascending: true)]
        return request
    }
    
    static func fetchAllNonHidden() -> NSFetchRequest<Course> {
        let request = fetchAll()
        request.predicate = NSPredicate(format: "hidden == NO")
        return request
    }
}
