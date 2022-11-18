//
//  ExerciseParticipationVM.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.11.22.
//

import Foundation

class ExerciseParticipationViewModel: ObservableObject {
    @Published var pointsText: String = "-" {
        didSet {
            let filtered = pointsText.filter { "0123456789.-".contains($0) }
            if filtered != pointsText {
                self.pointsText = filtered
            }
            self.examExerciseParticipation.points = Double(self.pointsText) ?? -1.0
        }
    }
    @Published var examExerciseParticipation: ExamParticipationExercise
    
    init(examExerciseParticipation: ExamParticipationExercise) {
        self.examExerciseParticipation = examExerciseParticipation
        if examExerciseParticipation.points < 0.0 {
            self.pointsText = "-"
        } else {
            self.pointsText = String(format: "%.2f", examExerciseParticipation.points)
        }
    }
    
    func checkMax(maxPoints: Double) {
        print("Check Max: \(maxPoints) for current Value \(self.pointsText)")
        guard let convertedValue = Double(self.pointsText) else { self.pointsText = "-"; return }
        if convertedValue > maxPoints {
            self.pointsText = "-"
        }
    }
}

extension ExamViewModel {
    class ExerciseParticipationVM: ObservableObject {
        var student: Student
        
        var points: Double? {
            get {
                Double(pointsText)
            }
            
            set {
                if let newValue {
                    pointsText = String(format: "%.2f", newValue)
                } else {
                    pointsText = "-"
                }
                
            }
        }
        
        @Published var pointsText: String = "-" {
            didSet {
                let filtered = pointsText.filter { "0123456789.-".contains($0) }
                if filtered != pointsText {
                    self.pointsText = filtered
                }
            }
        }
        
        
        init(student: Student) {
            self.student = student
        }
        
        func checkMax(maxPoints: Double) {
            print("Check Max: \(maxPoints) for current Value \(self.pointsText)")
            guard let convertedValue = Double(self.pointsText) else { self.pointsText = "-"; return }
            if convertedValue > maxPoints {
                self.pointsText = "-"
            }
        }
    }
}
