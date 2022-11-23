//
//  ExamParticipation+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 18.11.22.
//

import Foundation


extension ExamParticipation {
    
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
