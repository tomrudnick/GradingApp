//
//  ExamParticipationExercise+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.11.22.
//

import Foundation
import CoreData

extension ExamParticipationExercise {
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
    
    convenience init(exercise: ExamExercise, examParticipation: ExamParticipation, context: NSManagedObjectContext) {
        self.init(context: context)
        self.examParticipation = examParticipation
        self.exercise = exercise
        self.id = UUID()
    }
}
