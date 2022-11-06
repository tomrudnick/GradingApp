//
//  ExerciseVM.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.11.22.
//

import Foundation

extension ExamViewModel {
    
    class ExerciseVM : ObservableObject, Hashable {
        var id: UUID
        @Published var title: String
        @Published var maxPointsText: String = "0" {
            didSet {
                let filtered = maxPointsText.filter { "0123456789.".contains($0) }
                if filtered != maxPointsText {
                    self.maxPointsText = filtered
                }
            }
        }
        @Published var participations: [ExerciseParticipationVM] = []
        
        
        var maxPoints: Double {
            get { Double(maxPointsText) ?? 0.0 }
            set { maxPointsText = String(format: "%.2f", newValue) }
        }
        
        init(id: UUID = UUID(), title: String, maxPoints: Double, participations: [ExerciseParticipationVM]) {
            self.title = title
            self.id = id
            self.maxPoints = maxPoints
            self.participations = participations
        }
        
       
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: ExamViewModel.ExerciseVM, rhs: ExamViewModel.ExerciseVM) -> Bool {
            lhs.id == rhs.id
        }
    }
}
