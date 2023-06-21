//
//  ExerciseVM.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.11.22.
//

import Foundation

class ExerciseViewModel: ObservableObject, Hashable {
    
    @Published var exerciseName: String {
        didSet {
            if self.exericse.name != exerciseName {
                self.exericse.name = exerciseName
                self.exericse.exam?.objectWillChange.send()
            }
        }
    }
    
    @Published var maxPointsText: String {
        didSet {
            let filtered = maxPointsText.filter { "0123456789.".contains($0) }
            if filtered != maxPointsText {
                self.maxPointsText = filtered
            }
            
            let newMaxPoints = Double(maxPointsText) ?? self.exericse.maxPoints
            
            if self.exericse.maxPoints != newMaxPoints {
                self.exericse.maxPoints = newMaxPoints
            }
        }
    }
    @Published var exericse: ExamExercise
    
    init(exericse: ExamExercise) {
        self.exericse = exericse
        self.maxPointsText = String(format: "%.2f", exericse.maxPoints)
        self.exerciseName = exericse.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(exericse.index)
    }
    
    static func == (lhs: ExerciseViewModel, rhs: ExerciseViewModel) -> Bool {
        lhs.exericse.index == rhs.exericse.index
    }
}
