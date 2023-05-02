//
//  ExamSchoolReportExportPopup.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.05.23.
//

import SwiftUI
import PDFKit

struct ExamSchoolReportExportPopup: View {
    
    var exam: Exam
    
    @Binding var dismiss: Bool
    
    @State var showImportDialog = false
    @State var showExportDialog = false
    
    @State var generatingExportFile = false
    @State var exportedFile: PDFFile?
    
    @State var importedFile: PDFDocument?
    @State var importedFileName: String?
    
    var shortFileName: String {
        guard let importedFileName else { return "" }
        if importedFileName.count >= 60 {
            return String(importedFileName.prefix(60))
        }
        return importedFileName
    }
    
    @State var showErrorAlert = false
    @State var errorMessage = ""
    

    
    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemBackground)
            VStack (alignment: .leading){
                HStack {
                    Button {
                        self.dismiss = true
                    } label: {
                        Text("Abbrechen")
                    }
                    .buttonStyle(.bordered)
                    Text("Schulleitungsreport")
                        .font(.title)
                }.padding([.leading, .bottom, .top ])
                HStack {
                    Text("Sie können den Schulleitungsreport direkt exportieren oder vorher eine Datei importieren und anhängen.")
                        .fontWeight(.light)
                    Spacer()
                }.padding(.leading)
                HStack {
                    Button("Importieren") {
                        self.showImportDialog.toggle()
                    }
                    .buttonStyle(.bordered)
                    if importedFileName != nil {
                        Text(shortFileName)
                            .fontWeight(.thin)
                        Button {
                            withAnimation {
                                self.importedFile = nil
                                self.importedFileName = nil
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }.padding()
                HStack {
                    Button("Exportieren") {
                        self.generateExportFile()
                    }.buttonStyle(.bordered)
                    if generatingExportFile {
                        ProgressView().padding(.leading)
                    }
                }.padding()
                Spacer()
            }
        }
        .cornerRadius(10)
        .frame(width: 500, height: 500)
        .fileImporter(isPresented: $showImportDialog, allowedContentTypes: [.pdf]) { result in
            fileImportCompletionHandler(result: result)
        }
        .fileExporter(isPresented: $showExportDialog, document: exportedFile, contentType: .pdf) { result in
            fileExportCompletionHandler(result: result)
        }
        .alert("Fehler", isPresented: $showErrorAlert) {
            Button("Ok") { }
        } message: {
            Text(errorMessage)
        }

    }
    
    @MainActor
    func generatePDFFromExam() async -> PDFFile {
        return PDFFile.generatePDFFromExam(exam: exam)
    }
    
    func generateExportFile() {
        Task {
            self.generatingExportFile = true
            let officalResult = await generatePDFFromExam()
            let exportFile: PDFFile
            if let importedFile {
                exportFile = PDFFile.mergePdf(data: officalResult.data, otherPdfDocument: importedFile,
                                              fileName: "\(exam.name)_\(exam.course?.name ?? "")_Rudnick_Schulleitung")
            } else {
                exportFile = officalResult
            }
            self.exportedFile = exportFile
            self.generatingExportFile = false
            self.showExportDialog = true
        }
    }
    
    func fileExportCompletionHandler(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("Saved to \(url)")
            self.importedFile = nil
            self.importedFileName = nil
            self.dismiss = true
        case .failure(let error):
            self.errorMessage = "File could not be exported: \(error.localizedDescription)"
            self.showErrorAlert = true
        }
    }
    

    func fileImportCompletionHandler(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            let selectedFileURL = url
            guard selectedFileURL.startAccessingSecurityScopedResource() else {
                showFileImportError(errorMessage: "File Security Scoped Resource could not have been accessed")
                return
            }
            
            guard let pdfDocument = PDFDocument(url: selectedFileURL) else {
                showFileImportError(errorMessage: "Could not create PDFDocument")
                return
            }
            
            self.importedFile = pdfDocument
            self.importedFileName = selectedFileURL.lastPathComponent
            
            selectedFileURL.stopAccessingSecurityScopedResource()
        case .failure(let error):
            showFileImportError(errorMessage: error.localizedDescription)
        }
    }
    
    func showFileImportError(errorMessage: String = "") {
        self.errorMessage = "The File could not be imported: \(errorMessage)"
        self.showErrorAlert = true
    }
    
    
}

