//
//  ExamParticipation+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 18.11.22.
//

import Foundation
import CoreData

extension ExamParticipation {
    
    public var id: UUID {
        get {
            if let id_ { return id_ }
            else {
                id_ = UUID()
                return id_!
            }
        }
        
        set {
            id_ = newValue
        }
    }
    
    convenience init(context: NSManagedObjectContext, student: Student, exam: Exam) {
        self.init(context: context)
        self.id = UUID()
        self.student = student
        self.exam = exam
        self.participated = true
    }
    
    var participatedExercises: Set<ExamParticipationExercise> {
        get { participatedExercises_ as? Set<ExamParticipationExercise> ?? [] }
        set { participatedExercises_  = newValue as NSSet }
    }
    
    func getGrade() -> Int {
        guard let exam, let student else { return -1 }
        var grade = exam.getGrade(for: student)
        if exam.course?.ageGroup == .lower {
            grade = Grade.convertLowerGradeToPoints(grade: grade)
        }
        return grade
    }
}
