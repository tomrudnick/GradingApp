//
//  Student.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.08.21.
//

import Foundation

class Student : Identifiable{
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    weak var course: Course?
    var grades: [Grade]
    
    init(id: String = UUID().uuidString, firstName: String, lastName: String, email: String, course: Course?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.course = course
        self.grades = []
    }
    
    var oralMark: Double {
        let oralGrades = grades.filter({$0.type == .oral}).map({$0.value})
        let sum = oralGrades.reduce(0, +)
        return Double(sum) / Double(oralGrades.count).round(digits: 3)
    }
    
}
