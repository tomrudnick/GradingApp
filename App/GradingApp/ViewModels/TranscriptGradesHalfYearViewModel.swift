//
//  TranscriptGradesHalfYearViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//

import Foundation
import CoreData

class TranscriptGradesHalfYearViewModel : TranscriptGradesViewModelProtocol {
    @Published var studentGrades: [GradeStudent<TranscriptGrade>]
    private(set) var halfYear: HalfType
    private(set) var course: Course?
    init() {
        self.course = nil
        self.halfYear = .firstHalf
        self.studentGrades = []
    }
    //You need to make sure that this method is called before fetching data
    func setHalf(halfYear: HalfType) {
        self.halfYear = halfYear
    }
    
    func fetchData(course: Course) {
        self.course = course
        self.studentGrades = course.studentsArr.map({ student in
            GradeStudent(student: student, grade: student.transcriptGrade, value: student.transcriptGrade?.getTranscriptGradeHalfValue(half: halfYear) ?? -1)
        }).sorted(by: {Student.compareStudents($0.student, $1.student)})

    }
    
    func setGrade(for student: Student, value: Int) {
        GradeStudent<TranscriptGrade>.setGrade(studentGrades: &studentGrades, for: student, value: value)
    }
    
    func save(viewContext: NSManagedObjectContext) {
        for studentGrade in studentGrades {
            if let grade = studentGrade.grade {
                do {
                    try grade.setTranscriptGradeHalfValue(half: halfYear, value: studentGrade.value)
                } catch {
                    print(error)
                }
                print("Updated Transcript Grade")
                viewContext.saveCustom()
            } else {
                TranscriptGrade.addTranscriptGradeWithHalfValue(courseType: course!.type, value: studentGrade.value, half: halfYear, student: studentGrade.student, context: viewContext)
                print("Added Transcript Grade")
            }
        }
        
        studentGrades.forEach {
            $0.student.objectWillChange.send()
        }
    }
}
