//
//  EditGradesPerDateViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import Foundation
import CoreData

class EditGradesPerDateViewModel : ObservableObject {
    @Published var studentGrades: [GradeStudent]
    
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
    
    init(studentGrades: [GradeStudent], course: Course) {
        
        //This code is probably not needed but we leave it for security reasons! Should be heavily tested!!
        let nonNilStudentGrades = studentGrades.filter{ $0.grade != nil }
        let comments = nonNilStudentGrades.map{ $0.grade!.comment! }
        if let comment = comments.first, comments.allSatisfy({$0 == comment}) {
            self.comment = comment
        } else {
            self.comment = nil
        }
        
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
            !studentGrades.contains(where: {$0.student == student})
        }.forEach({tmpStudentGrades.append(GradeStudent(student: $0))})
        self.studentGrades = tmpStudentGrades.sorted { $0.student.firstName < $1.student.firstName }.sorted{ $0.student.lastName < $1.student.lastName }
        self.course = course
        
    }
    
    func setGrade(for student: Student, value: Int) {
        if let studentIndex = studentGrades.firstIndex(where: {$0.student == student}) {
            studentGrades[studentIndex].value = value
        }
    }
    
    func save(viewContext: NSManagedObjectContext) -> Void {
        for studentGrade in studentGrades {
            if let grade = studentGrade.grade {
                grade.value = Int32(studentGrade.value)
                grade.date = date
                if let multiplier = gradeMultiplier {
                    grade.multiplier = multiplier
                }
                
                if let comment = comment {
                    grade.comment = comment
                }
                viewContext.saveCustom()
            } else if studentGrade.value != -1 {
                Grade.addGrade(value: studentGrade.value, date: date, half: .firstHalf, type: gradeType, comment: comment ?? "", multiplier: gradeMultiplier ?? 1.0, student: studentGrade.student, context: viewContext)
            }
        }
    }
}