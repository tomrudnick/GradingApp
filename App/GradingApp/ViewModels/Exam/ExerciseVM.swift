//
//  ExerciseVM.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.11.22.
//

import Foundation

class ExerciseViewModel: ObservableObject, Hashable {
    @Published var maxPointsText: String {
        didSet {
            let filtered = maxPointsText.filter { "0123456789.".contains($0) }
            if filtered != maxPointsText {
                self.maxPointsText = filtered
            }
            self.exericse.maxPoints = Double(maxPointsText) ?? self.exericse.maxPoints
        }
    }
    @Published var exericse: ExamExercise
    
    init(exericse: ExamExercise) {
        self.exericse = exericse
        self.maxPointsText = String(format: "%.2f", exericse.maxPoints)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(exericse.index)
    }
    
    static func == (lhs: ExerciseViewModel, rhs: ExerciseViewModel) -> Bool {
        lhs.exericse.index == rhs.exericse.index
    }
}
