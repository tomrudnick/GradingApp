//
//  EditGradesPerDateViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import Foundation
import CoreData

class EditGradesPerDateViewModel : ObservableObject {
    @Published var studentGrades: [GradeStudent<Grade>]
    
    @Published var comment: String?
    @Published var date: Date
    @Published var gradeMultiplier: Double?
    @Published var course: Course
    @Published var gradeType: GradeType
    
    var gradeTypeNumber: Int {
        get {
            gradeType == .oral ? 0 : 1
        }
        set {
            gradeType = newValue == 0 ? .oral : .written
        }
    }
    
    var gradeMultiplierNumber: Int {
        get {
            Grade.gradeMultiplier.firstIndex(where: {$0 == gradeMultiplier ?? 1.0}) ?? -1
        }
        set {
            gradeMultiplier = Grade.gradeMultiplier[newValue]
        }
    }
    //This hole init function should be heavily tested!!!
    init(studentGrades: [GradeStudent<Grade>], course: Course) {
        self.comment = Grade.getComment(studentGrades: studentGrades)
        let nonNilStudentGrades = studentGrades.filter{ $0.grade != nil }
        let multipliers = nonNilStudentGrades.map{$0.grade!.multiplier}
        if let multiplier = multipliers.first, multipliers.allSatisfy({$0 == multiplier}) {
            self.gradeMultiplier = multiplier
        } else {
            self.gradeMultiplier = nil
        }
        // If this force unwrap fails the caller of this Class made a mistake!
        self.date = nonNilStudentGrades.first!.grade!.date!
        self.gradeType = nonNilStudentGrades.first!.grade!.type
        // Add missing students
        var tmpStudentGrades = studentGrades
        course.students.filter { student in
            !studentGrades.contains(where: {$0.student == student}) && student.hidden == false
        }.forEach({tmpStudentGrades.append(GradeStudent(student: $0))})
        self.studentGrades = tmpStudentGrades.sorted(by: {Student.compareStudents($0.student, $1.student) })

        self.course = course
        
    }
    
    func setGrade(for student: Student, value: Int) {
        GradeStudent<Grade>.setGrade(studentGrades: &studentGrades, for: student, value: value)
    }
    
    func save(viewContext: NSManagedObjectContext, halfYear: HalfType) -> Void {
        for studentGrade in studentGrades {
            if let grade = studentGrade.grade {
                if studentGrade.value == -1 {
                    viewContext.delete(grade)
                } else {
                    grade.value = Int32(studentGrade.value)
                    grade.date = date
                    grade.type = gradeType
                    if let multiplier = gradeMultiplier {
                        grade.multiplier = multiplier
                    }
                    //reset grade Multiplier if gradeType changes to written
                    if gradeType == .written {
                        grade.multiplier = 1.0
                    }
                    
                    if let comment = comment {
                        grade.comment = comment
                    }
                }
                viewContext.saveCustom()
            } else if studentGrade.value != -1 {
                Grade.addGrade(value: studentGrade.value, date: date, half: halfYear, type: gradeType, comment: comment ?? "", multiplier: gradeMultiplier ?? 1.0, student: studentGrade.student, context: viewContext)
            }
        }
    }
    
    func delete(viewContext: NSManagedObjectContext) {
        self.studentGrades.forEach({if let grade = $0.grade { viewContext.delete(grade)}})
        //viewContext.saveCustom()
    }
}
