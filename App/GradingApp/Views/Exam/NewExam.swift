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
        case exercise(ExamViewModel.ExerciseVM)
    }
    
    var course: Course
    @StateObject var examVM = ExamViewModel()
    @State var selection: ExamRoute? = .dashboard
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: ExamRoute.dashboard) { Text("Dashboard") }
                NavigationLink(value: ExamRoute.participants) { Text("Teilnehmer") }
                NavigationLink(value: ExamRoute.gradingScheme) { Text("Noten Schema") }
                Section("Aufgaben") {
                    ForEach(examVM.exercises, id: \.id) { exercise in
                        NavigationLink(value: ExamRoute.exercise(exercise)) {
                            HStack {
                                Text(exercise.title)
                                Spacer()
                                Text(exercise.maxPointsText).foregroundColor(Color.gray)
                            }
                        }
                    }
                    .onDelete(perform: examVM.delete)
                    .onMove(perform: examVM.move)
                }
            }
            .navigationTitle("Exam: \(examVM.title)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        examVM.addExercise(maxPoints: 0.0)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .secondaryAction) { EditButton() }
            }
        } detail: {
            switch selection ?? .dashboard {
            case .dashboard: ExamDashboard(examVM: examVM)
            case .gradingScheme: ExamGradingSchemeView(examVM: examVM)
            case .participants: ExamParticipantsView(examVM: examVM)
            case .exercise(let exerciseVM): ExerciseView(examVM: examVM, exercise: exerciseVM)
            }
        }
        .onAppear {
            examVM.initVM(course: course)
        }

    }
}

/*struct NewExam_Previews: PreviewProvider {
    static var previews: some View {
        NewExam()
    }
}*/
