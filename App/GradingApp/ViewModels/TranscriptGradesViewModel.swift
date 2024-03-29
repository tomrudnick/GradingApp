//
//  TranscriptGradesViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 01.09.21.
//

import Foundation
import CoreData

protocol TranscriptGradesViewModelProtocol : ObservableObject {
    var studentGrades: [GradeStudent<TranscriptGrade>] { get set }
    var course: Course? { get }
    func fetchData(course: Course) //This could maybe be removed in the future
    func setGrade(for student: Student, value: Int)
    func save(viewContext: NSManagedObjectContext)
}
/**
 The TranscriptGradesViewModel only fetches the transcriptGrades that are not nil. That means you can only set transcript grades for
 Students that allready have **at least** one half transcript grade!
 */
class TranscriptGradesViewModel : TranscriptGradesViewModelProtocol {
    @Published var studentGrades: [GradeStudent<TranscriptGrade>]
    private(set) var course: Course?
    
    init() {
        self.course = nil
        self.studentGrades = []
    }
    
    func fetchData(course: Course) {
        self.course = course
        self.studentGrades = course.studentsArr
            .filter({$0.transcriptGrade != nil})
            .map({ student in
                GradeStudent(student: student, grade: student.transcriptGrade)
            }).sorted(by: {Student.compareStudents($0.student, $1.student)})
    }
    
    func setGrade(for student: Student, value: Int) {
        GradeStudent<TranscriptGrade>.setGrade(studentGrades: &studentGrades, for: student, value: value)
    }

    func save(viewContext: NSManagedObjectContext) {
        for studentGrade in studentGrades {
            //since we filtered the grades for non nil objects this should allways succeed
            if let grade = studentGrade.grade {
                grade.value = Int32(studentGrade.value)
            }
            viewContext.saveCustom()
        }
        
        studentGrades.forEach {
            $0.student.objectWillChange.send()
        }
    }
}
