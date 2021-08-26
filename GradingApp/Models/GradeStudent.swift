//
//  GradeStudent.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import Foundation

// This Model should be a simple way to associate a specific grade to a specific student
// Furthermore the value Var is the grade.value in order to change it without editing the grade directly
struct GradeStudent : Identifiable {
    var id: UUID = UUID()
    let student: Student
    let grade: Grade?
    var value: Int
    
    init(student: Student, grade: Grade) {
        self.student = student
        self.grade = grade
        self.value = Int(grade.value)
    }
    
    init(student: Student) {
        self.student = student
        self.grade = nil
        self.value = -1
    }
}
