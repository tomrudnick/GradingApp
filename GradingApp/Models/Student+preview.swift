//
//  Student+preview.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.08.21.
//

import Foundation
import CoreData

extension Student {
    static func exampleStudent(context: NSManagedObjectContext) -> Student {
        let student = Student(context: context)
        student.firstName = "Marit"
        student.lastName = "Abken"
        return student
    }
}
