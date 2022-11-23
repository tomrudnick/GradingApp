//
//  ExamExercise+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import Foundation

extension ExamExercise {
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    var participationExercises: Set<ExamParticipationExercise> {
        get { participationExercises_ as? Set<ExamParticipationExercise> ?? [] }
        set { participationExercises_ = newValue as NSSet }
    }
}
