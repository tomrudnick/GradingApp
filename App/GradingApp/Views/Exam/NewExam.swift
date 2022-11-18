//
//  NewExam.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import SwiftUI

struct NewExam: View {
    
    enum ExamRoute: Hashable {
        case dashboard
        case participants
        case gradingScheme
        case exercise(ExerciseViewModel)
    }
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var exam: Exam
    @State var selection: ExamRoute? = .dashboard
    
    let save: () -> ()
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: ExamRoute.dashboard) { Text("Dashboard") }
                NavigationLink(value: ExamRoute.participants) { Text("Teilnehmer") }
                NavigationLink(value: ExamRoute.gradingScheme) { Text("Noten Schema") }
                Section("Aufgaben") {
                    ForEach(exam.exercisesArr) { exercise in
                        let exerciseVM = ExerciseViewModel(exericse: exercise)
                        NavigationLink(value: ExamRoute.exercise(exerciseVM)) {
                           ExerciseRowView(exercise: exercise)
                        }
                    }
                    .onDelete(perform: exam.delete)
                    .onMove(perform: exam.move)
                }
            }
            .navigationTitle("Exam: \(exam.name)")
            .toolbar { toolbar }
        } detail: {
            switch selection ?? .dashboard {
            case .dashboard: ExamDashboard(exam: exam)
            case .gradingScheme: ExamGradingSchemeView(exam: exam)
            case .participants: ExamParticipantsView(exam: exam)
            case .exercise(let exerciseVM): ExerciseView(exam: exam, exerciseVM: exerciseVM)
            }
        }
    }
    
    @ToolbarContentBuilder var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                exam.addExercise(maxPoints: 0.0)
            } label: {
                Image(systemName: "plus")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                save()
            } label: {
                Image(systemName: "externaldrive")
            }
        }
        ToolbarItem(placement: .secondaryAction) { EditButton() }
        ToolbarItem(placement: .cancellationAction) {
            Button {
                dismiss()
            } label: {
                Text("Abbrechen")
            }
        }
    }
}

struct ExerciseRowView: View {
    @ObservedObject var exercise: ExamExercise
    
    var body: some View {
        HStack {
            Text(exercise.name)
            Spacer()
            Text(String(format: "%.2f", exercise.maxPoints))
        }
    }
}

/*struct NewExam_Previews: PreviewProvider {
    static var previews: some View {
        NewExam()
    }
}*/
