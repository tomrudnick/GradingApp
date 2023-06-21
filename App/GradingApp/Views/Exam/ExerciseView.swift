//
//  ExerciseView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI
import Combine

struct ExerciseView: View {
    
    var exam: Exam
    @ObservedObject var exerciseVM: ExerciseViewModel

    var body: some View {
        
        Form {
            Section("Exercise Settings") {
                HStack {
                    Text("Exercise Name: ")
                    TextField("Aufgabe...", text: $exerciseVM.exerciseName)
                }
                HStack {
                    Text("Max Points: ")
                    TextField("Max Punkte...", text: $exerciseVM.maxPointsText)
                }
            }
            
            Section("Students Points for Exercise") {
                List {
                    ForEach(onlyParticpantsSorted()) { exerciseParticipation in
                        let epvm = ExerciseParticipationViewModel(examExerciseParticipation: exerciseParticipation)
                        ExerciseParticipationView(epvm: epvm, maxPoints: exerciseVM.exericse.maxPoints)
                    }
                }
            }
        }
        .navigationTitle("Aufgabe \(exerciseVM.exericse.name)")
    }
    
    func onlyParticpantsSorted() -> [ExamParticipationExercise] {
        exerciseVM.exericse.participationExercises
            .filter {
                guard let examParticipation = $0.examParticipation else { return false }
                return exam.examParticipations.first { $0 == examParticipation }?.participated ?? false
            }
            .sorted { p1, p2 in
                guard let s1 = p1.examParticipation?.student, let s2 = p2.examParticipation?.student else { return false }
                return Student.compareStudents(s1, s2)
            }
    }
}


