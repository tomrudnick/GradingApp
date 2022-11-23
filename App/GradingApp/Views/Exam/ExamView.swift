//
//  ExamView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import SwiftUI

struct ExamView: View {
    
    enum ExamRoute: Hashable {
        case dashboard
        case participants
        case gradingScheme
        case exercise(ExerciseViewModel)
    }
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var exam: Exam
    @State var selection: ExamRoute? = .dashboard
    @State var showPDFExporter = false
    
    let save: () -> ()
    let delete: () -> ()
    
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
            .fileExporter(isPresented: $showPDFExporter, document: PDFFile.generatePDFFromExam(exam: exam), contentType: .pdf) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
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
       
        ToolbarItem(placement: .cancellationAction) {
            Menu {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                }
                Button {
                    save()
                    dismiss()
                } label: {
                    HStack {
                        Text("Speichern")
                        Image(systemName: "externaldrive")
                    }
                }
                Button {
                    delete()
                    self.dismiss()
                } label: {
                    Text("Löschen")
                    Image(systemName: "trash")
                }
                Button {
                    self.showPDFExporter.toggle()
                } label: {
                    Text("Export")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
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
        ExamView()
    }
}*/
