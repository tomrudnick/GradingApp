//
//  TranscriptGradesHalfYearViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//

import Foundation
import CoreData

class TranscriptGradesHalfYearViewModel : ObservableObject {
    @Published var studentGrades: [GradeStudent<TranscriptGrade>]
    private(set) var halfYear: HalfType
    private(set) var course: Course?
    init() {
        self.course = nil
        self.halfYear = .firstHalf
        self.studentGrades = []
    }
    
    func fetchData(course: Course, halfYear: HalfType) {
        self.course = course
        self.halfYear = halfYear
        self.studentGrades = course.studentsArr.map({ student in
            GradeStudent(student: student, grade: student.transcriptGrade, value: student.transcriptGrade?.getTranscriptGradeHalfValue(half: halfYear) ?? -1)
        }).sorted(by: {$0.student.firstName < $1.student.firstName}).sorted(by: {$0.student.lastName < $1.student.lastName })
    }
    
    func setGrade(for student: Student, value: Int) {
        GradeStudent<TranscriptGrade>.setGrade(studentGrades: &studentGrades, for: student, value: value)
    }
    
    func save(viewContext: NSManagedObjectContext) {
        for studentGrade in studentGrades {
            if let grade = studentGrade.grade {
                if studentGrade.value == -1 {
                    viewContext.delete(grade)
                } else {
                    do {
                        try grade.setTranscriptGradeHalfValue(half: halfYear, value: studentGrade.value)
                    } catch {
                        print(error)
                    }
                }
                print("Updated Transcript Grade")
                viewContext.saveCustom()
            } else {
                TranscriptGrade.addTranscriptGradeWithHalfValue(courseType: course!.type, value: studentGrade.value, half: halfYear, student: studentGrade.student, context: viewContext)
                print("Added Transcript Grade")
            }
        }
    }
}
