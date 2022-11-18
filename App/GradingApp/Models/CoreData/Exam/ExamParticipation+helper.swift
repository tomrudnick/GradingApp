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
}
