//
//  ExerciseView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI
import Combine

struct ExerciseView: View {
    
    var examVM: ExamViewModel
    @ObservedObject var exercise: ExamViewModel.ExerciseVM
    
    var body: some View {
        
        Form {
            Section("Exercise Settings") {
                HStack {
                    Text("Exercise Name: ")
                    TextField("Aufgabe...", text: $exercise.title)
                        .onChange(of: exercise.title) { _ in
                            examVM.objectWillChange.send()
                        }
                }
                HStack {
                    Text("Max Points: ")
                    TextField("Max Punkte...", text: $exercise.maxPointsText)
                }
            }
            
            Section("Students Points for Exercise") {
                List {
                    ForEach(onlyParticpantsSorted(), id: \.student) { exerciseParticipation in
                        ExerciseParticipationView(epvm: exerciseParticipation, maxPoints: exercise.maxPoints)
                    }
                }
            }
        }
        .navigationTitle("Exercise \(exercise.title)")
    }
    
    func onlyParticpantsSorted() -> [ExamViewModel.ExerciseParticipationVM] {
        exercise.participations
            .filter { examVM.participants[$0.student] == true }
            .sorted { Student.compareStudents($0.student, $1.student) }
    }
}


