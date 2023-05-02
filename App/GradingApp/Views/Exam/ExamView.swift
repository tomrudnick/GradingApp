//
//  ExamView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import SwiftUI
import PDFKit

struct ExamView: View {
    
    enum ExamRoute: Hashable {
        case dashboard
        case participants
        case gradingScheme
        case exercise(ExerciseViewModel)
    }
    
    enum AlertType {
        case delete
        case close
        case countMismatch
        case export
    }
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var exam: Exam
    @State var selection: ExamRoute? = .dashboard
    @State var showStudentPDFsExporter = false
    @State var showStudentExamPDFsExporter = false
    @State var showStudentExamFileImporter = false
    @State var showStudentCSVExporter = false
    @State var showPDFImport = false
    @State var showExportSchoolOfficial = false
    @State private var editMode: EditMode = .inactive
    @State var showAlert = false
    @State var alertType: AlertType = .delete
    
    @State var exportAlertText = ""
    
    @State var exportedExams: [PDFFile] = []

    
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
            }.environment(\.editMode, $editMode)
            .navigationTitle("Exam: \(exam.name)")
            .toolbar { toolbar }
            .if(showStudentPDFsExporter, transform: { view in
                view.fileExporter(isPresented: $showStudentPDFsExporter, documents: PDFFile.generatePDFsFromExam(exam: exam), contentType: .pdf, onCompletion: { result in
                    switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            })
            .if(showStudentExamPDFsExporter, transform: { view in
                view.fileExporter(isPresented: $showStudentExamPDFsExporter, documents: exportedExams, contentType: .pdf, onCompletion: { result in
                    switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            })
            .if(showStudentCSVExporter, transform: { view in
                view.fileExporter(isPresented: $showStudentCSVExporter, document: CSVFile.generateStudentsListCSVFromExam(exam: exam), contentType: .commaSeparatedText) { result in
                    switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            })
            .fileImporter(isPresented: $showStudentExamFileImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: true, onCompletion: { result in
                do {
                    exportedExams =  try PDFFile.pdfFileExamImporter(exam: exam, result: result).map(\.value)
                    self.showStudentExamPDFsExporter.toggle()
                } catch ImportError.countMissmatch {
                    self.alertType = .countMismatch
                    self.showAlert.toggle()
                } catch ImportError.matchInsecurity(let possibleMissmatches, let exportedExams){
                    exportAlertText = ""
                    for missmatch in possibleMissmatches {
                        exportAlertText += "Student: \(missmatch.student.firstName) \(missmatch.student.lastName) FileName: \(missmatch.fileName) Score: \(missmatch.score)\n"
                    }
                    alertType = .export
                    showAlert.toggle()
                    self.exportedExams = exportedExams.map(\.value)
                } catch (let error) {
                    print(error.localizedDescription)
                }
                            
            })
            .alert("Achtung", isPresented: $showAlert, actions: {
                switch alertType {
                case .delete: deleteAlertActions
                case .close: closeAlertActions
                case .countMismatch: countMismatchAlertActions
                case .export : exportAlertActions
                }
            }, message: {
                switch alertType {
                case .delete: Text("Möchten sie diese Klausur wirklich löschen??")
                case .close: Text("Möchten sie wirklich schließen? Alle nicht gespeicherten Änderungen gehen verloren!")
                case .export: Text(exportAlertText)
                case .countMismatch: Text("Schüler Anzahl und Anzahl Klassenarbeiten stimmt nicht überein")
                }
            })
        } detail: {
            switch selection ?? .dashboard {
            case .dashboard: ExamDashboard(exam: exam)
            case .gradingScheme: ExamGradingSchemeView(exam: exam)
            case .participants: ExamParticipantsView(exam: exam)
            case .exercise(let exerciseVM): ExerciseView(exam: exam, exerciseVM: exerciseVM)
            }
        }.popup(isPresented: $showExportSchoolOfficial, darkBackground: true, view: {
            ExamSchoolReportExportPopup(exam: exam, dismiss: $showExportSchoolOfficial.not)
        })
    }

    var deleteAlertActions: some View {
        Group {
            Button("Ja!") { delete(); self.dismiss() }
            Button("Abbrechen") { }
        }
    }
    
    var closeAlertActions: some View {
        Group {
            Button("Ja!") { self.dismiss() }
            Button("Abbrechen") { }
        }
    }
    
    var countMismatchAlertActions: some View {
        Button("Ok") { }
    }
    
    var exportAlertActions: some View {
        Group {
            Button("Fortfahren") { self.showStudentExamPDFsExporter.toggle() }
            Button("Abbrechen") { self.exportedExams = [] }
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
                if editMode == .inactive {
                    editMode = .active
                } else {
                    editMode = .inactive
                }
            } label: {
                Text(editMode == .inactive ? "Edit" : "Done")
            }
        }
        ToolbarItem(placement: .cancellationAction) {
            Menu {
                Button {
                    self.alertType = .close
                    self.showAlert.toggle()
                } label: {
                    Text("Schließen")
                }
                Button {
                    save()
                } label: {
                    HStack {
                        Text("Speichern")
                        Image(systemName: "externaldrive")
                    }
                }
                Button {
                    self.alertType = .delete
                    self.showAlert.toggle()
                } label: {
                    Text("Löschen")
                    Image(systemName: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
            }
        }
        ToolbarItem(placement: .cancellationAction) {
            Menu {
        
                Button {
                    self.showExportSchoolOfficial.toggle()
                } label: {
                    Text("Export Ergebnisse für Schulleitung")
                }
                
                Button {
                    self.showStudentPDFsExporter.toggle()
                } label: {
                    Text("Notendeckblätter generieren")
                }
                Button {
                    self.showStudentExamFileImporter.toggle()
                } label: {
                    Text("Notendeckblätter an Klausur anhängen")
                }
                Button {
                    self.showStudentCSVExporter.toggle()
                } label: {
                    Text("Klassenarbeitsteilnehmer als csv-Datei exportieren")
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
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
            Text(String(format: "%.2f", exercise.averagePoints())+"%")
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
