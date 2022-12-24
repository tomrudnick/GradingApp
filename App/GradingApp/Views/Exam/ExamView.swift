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
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var exam: Exam
    @State var selection: ExamRoute? = .dashboard
    @State var showPDFExporter = false
    @State var showStudentPDFsExporter = false
    @State var showStudentExamFileImporter = false
    @State private var editMode: EditMode = .inactive
    @State var showDeleteAlert = false
    @State var showCloseAlert = false
    
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
            .if(showPDFExporter, transform: { view in
                view.fileExporter(isPresented: $showPDFExporter, document: PDFFile.generatePDFFromExam(exam: exam), contentType: .pdf, onCompletion: { result in
                    switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                })
            })
            .fileImporter(isPresented: $showStudentExamFileImporter, allowedContentTypes: [.pdf], allowsMultipleSelection: true, onCompletion: { result in
                do {
                    let selectedFiles = try result.get()
                    for file in selectedFiles {
                        print(file.lastPathComponent)
                    }
                } catch (let error) {
                    print(error.localizedDescription)
                }
            })
            .alert(isPresented: $showDeleteAlert) {
                Alert(title: Text("Achtung"),
                      message: Text("Möchten sie diese Klausur wirklich löschen??"),
                      primaryButton: Alert.Button.default(Text("Ja!"), action: { delete(); self.dismiss()}),
                      secondaryButton: Alert.Button.cancel(Text("Abbrechen"), action: { })
                )
            }.alert(isPresented: $showCloseAlert) {
                Alert(title: Text("Achtung"),
                      message: Text("Möchten sie wirklich schließen? Alle nicht gespeicherten Änderungen gehen verloren!"),
                      primaryButton: Alert.Button.default(Text("Ja!"), action: { self.dismiss()}),
                      secondaryButton: Alert.Button.cancel(Text("Abbrechen"), action: { })
                )
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
                    self.showCloseAlert.toggle()
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
                    self.showDeleteAlert.toggle()
                } label: {
                    Text("Löschen")
                    Image(systemName: "trash")
                }
                Button {
                    self.showPDFExporter.toggle()
                } label: {
                    Text("Export")
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
            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
            }
        }
    }
    
    func mergePdf(data: Data, otherPdfDocumentData: Data) -> PDFDocument {
        // get the pdfData
        let pdfDocument = PDFDocument(data: data)!
        let otherPdfDocument = PDFDocument(data: otherPdfDocumentData)!
        
        // create new PDFDocument
        let newPdfDocument = PDFDocument()

        // insert all pages of first document
        for p in 0..<pdfDocument.pageCount {
            let page = pdfDocument.page(at: p)!
            let copiedPage = page.copy() as! PDFPage // from docs
            newPdfDocument.insert(copiedPage, at: newPdfDocument.pageCount)
        }

        // insert all pages of other document
        for q in 0..<otherPdfDocument.pageCount {
            let page = pdfDocument.page(at: q)!
            let copiedPage = page.copy() as! PDFPage
            newPdfDocument.insert(copiedPage, at: newPdfDocument.pageCount)
        }
        return newPdfDocument
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
