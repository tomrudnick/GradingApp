//
//  GradeStudent.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import Foundation

// This Model should be a simple way to associate a specific grade to a specific student
// Furthermore the variable value is the grade.value in order to change it without editing the grade directly

protocol GradeValue: Hashable {
    var value: Int32 { get set }
}

extension Grade : GradeValue {
    
}

extension TranscriptGrade : GradeValue {
    
}

struct GradeStudent<G: GradeValue> : Identifiable, Hashable {
    var id: UUID = UUID()
    let student: Student
    let grade: G?
    var value: Int
    
    init(student: Student, grade: G?) {
        self.student = student
        self.grade = grade
        self.value = Int(grade?.value ?? -1)
    }
    
    init(student: Student, grade: G?, value: Int) {
        self.student = student
        self.grade = grade
        self.value = value
    }

    init(student: Student) {
        self.student = student
        self.grade = nil
        self.value = -1
    }
    
    static func setGrade<G: GradeValue>(studentGrades: inout [GradeStudent<G>], for student: Student, value: Int) {
        if let studentIndex = studentGrades.firstIndex(where: {$0.student == student}) {
            studentGrades[studentIndex].value = value
        }
    }
    
    static func getGradeAverage<G: GradeValue>(studentGrades: [GradeStudent<G>]) -> Double {
        let nonNilStudentGrades = studentGrades.filter {$0.grade != nil}
        let sum = nonNilStudentGrades.reduce(0.0) {$0 + Double($1.grade?.value ?? 0)}
        return sum / Double(nonNilStudentGrades.count)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(student)
        hasher.combine(grade)
        hasher.combine(value)
    }
}

