//
//  BackupRestoreView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 18.04.22.
//

import SwiftUI

//The logic should maybe be moved to a ViewModel
struct BackupRestoreView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingAlert = false
    @State private var selectedURL: URL?
    @State private var urls = BackupViewModel.getBackupFiles()
    var body: some View {
        VStack {
            HStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Abbrechen")
                }

                Spacer()
                Text("Backup auswählen").bold()
            }.padding()
            
            List {
                ForEach(urls, id: \.self) { url in
                    Button  {
                        self.showingAlert = true
                        self.selectedURL = url
                    } label: {
                        HStack {
                            Text(url.lastPathComponent)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }.contextMenu {
                        Button {
                            try? FileManager.default.removeItem(at: url)
                            urls = BackupViewModel.getBackupFiles()
                        } label: {
                            Text("Löschen")
                        }

                    }
                }.onDelete { indexSet in
                    indexSet.map { self.urls[$0] }.forEach { url in
                        try? FileManager.default.removeItem(at: url)
                    }
                    urls = BackupViewModel.getBackupFiles()
                }
            }
            
            HStack {
                Button {
                    for url in urls {
                        try? FileManager.default.removeItem(at: url)
                    }
                } label: {
                    Text("Alle Backups löschen").foregroundColor(.red).padding()
                }
            }
        }.alert("Möchtest du die Daten wirklich von diesem Backup wiederherstellen?", isPresented: $showingAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Ja!") {
                do {
                    let selectedFileData = try Data(contentsOf: selectedURL!)
                    PersistenceController.deleteAllCourses(viewContext: viewContext)
                    PersistenceController.resetAllCoreData()
                    let _ = try! JSONDecoder().decode([Course].self, from: selectedFileData)
                    viewContext.saveCustom()
                    print("Restore Process complete")
                    self.presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Something went wrong while resotring data")
                }
            }
        }
    }
}

