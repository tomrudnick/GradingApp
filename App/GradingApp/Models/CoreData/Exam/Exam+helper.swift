//
//  Exam+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import Foundation
import UIKit
import CoreData


extension Exam {
    var date: Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
    
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    var gradeSchema: Dictionary<Int, Double> {
        get { gradeSchema_ as? Dictionary<Int, Double> ?? [:] }
        set { gradeSchema_ = NSDictionary(dictionary: newValue) }
    }
    
    var exercises: Set<ExamExercise> {
        get { exercises_ as? Set<ExamExercise> ?? [] }
        set { exercises_ = newValue as NSSet }
    }
    
    var exercisesArr: Array<ExamExercise> {
        exercises.sorted { $0.name < $1.name }
    }
}
