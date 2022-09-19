//
//  MoreActionsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices
import UIKit
import CloudStorage

enum BackupType {
    case backup
    case export
}

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var emailViewModel = EmailAccountViewModel()
    @StateObject var backupSettingsViewModel: BackupViewModel
    
    @State var showHalfWarningAlert = false
    @State private var showingBackup = false
    @State private var showingRestore = false
    @State private var showingExport = false
    @State private var showingRestoreFromiCloud = false
    @State private var backupType: BackupType = .backup
    @ObservedObject var externalScreenHideViewModel: ExternalScreenHideViewModel
    
    @CloudStorage("Schuljahr")                  var activeSchoolYear:   String?
    @CloudStorage(HalfYearDateKeys.firstHalf)   var dateFirstHalf:      Date = Date()
    @CloudStorage(HalfYearDateKeys.secondHalf)  var dateSecondHalf:     Date = Date()
    
    @Binding var selectedHalf: HalfType
    
    var onDelete: () -> ()
    
    init(externalScreenHideViewModel: ExternalScreenHideViewModel, onDelete: @escaping () -> () = { }, selectedHalf: Binding<HalfType>) {
        self.onDelete = onDelete
        self.externalScreenHideViewModel = externalScreenHideViewModel
        self._backupSettingsViewModel = StateObject(wrappedValue: BackupViewModel())
        self._selectedHalf = selectedHalf
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Backup / Export")) {
                    Button {
                        self.showingBackup = true
                        backupType = .backup
                    } label: {
                        ZStack {
                            Text("Backup")
                        }
                    }
                    Button {
                        self.showingExport = true
                        backupType = .export
                    } label: {
                        Text("Export")
                    }
                }
                Section(header: Text("Backup-Einstellung")){
                    DatePicker("Backup Zeit", selection: $backupSettingsViewModel.backupTime, displayedComponents: .hourAndMinute)
                    NavigationLink(destination: BackupTimeIntervalView(selection: $backupSettingsViewModel.backupNotifyInterval)) {
                        HStack{
                            Text("Wiederholen")
                            Spacer()
                            Text(backupSettingsViewModel.backupNotifyInterval.rawValue).foregroundColor(.gray)
                        }
                    }
                
                }
                Section(header: Text("Import")) {
                    Button {
                        self.showingRestore = true
                    } label: {
                        Text("Import")
                    }
                    HStack {
                        Text("iCloud Backups: \(BackupViewModel.countBackupFiles())")
                        Spacer()
                        Button {
                            self.showingRestoreFromiCloud = true
                        } label: {
                            Text("Wiederherstellen")
                        }

                    }
                }
                //This is only for development code
                /*Section(header: Text("Temporary")) {
                    Button {
                        onDelete()
                        viewModel.deleteAllCourses(viewContext: viewContext)
                    } label: {
                        Text("Delete everything")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }*/
                
                Section(header: Text("Halbjahres Einstellung")) {
                    
                    DatePicker("Start 1. Halbjahr", selection: $dateFirstHalf, displayedComponents: [.date])
                        .id(dateFirstHalf) //Erzwingt den Datepicker einen rebuild des Views zu machen
                        .environment(\.locale, Locale.init(identifier: "de"))
                    
                    
                    DatePicker("Start 2. Halbjahr", selection: $dateSecondHalf, displayedComponents: [.date])
                        .id(dateSecondHalf) //Erzwingt den Datepicker einen rebuild des Views zu machen
                        .environment(\.locale, Locale.init(identifier: "de"))
                    
                    Picker(selection: $selectedHalf, label: Text("")) {
                        Text("1. Halbjahr").tag(HalfType.firstHalf)
                        Text("2. Halbjahr").tag(HalfType.secondHalf)
                    }.pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedHalf) { newValue in
                            showHalfWarningAlert = !halfCorrect()
                        }
                    
                }
                
                Section(header: Text("Schuljahr")) {
                    NavigationLink(destination: SchoolYearsView(activeSchoolYear: $activeSchoolYear)){
                        HStack {
                            Text("Schuljahr \(activeSchoolYear ?? "-")")
                            Spacer()
                            Text("Schuljahr wählen")
                        }
                    }
                }
                
                Section(header: Text("Externe Bildschirme blockieren")) {
                    Toggle("Verstecken:", isOn: $externalScreenHideViewModel.notHide.not)
                }
                
                Section(header: Text("Email Einstellungen")) {
                    Toggle("Email Account active: ", isOn: $emailViewModel.emailAccountUsed)
                    if emailViewModel.emailAccountUsed {
                        HStack {
                            Text("Hostname:")
                            Spacer()
                            TextField("sslout.server.com: ", text: $emailViewModel.hostname)
                                .disableAutocorrection(true)
                        }
                        HStack {
                            Text("Email:")
                            Spacer()
                            TextField("max@musterman.com", text: $emailViewModel.email)
                                .disableAutocorrection(true)
                        }
                        
                        
                       
                        HStack {
                            Text("Port:")
                            Spacer()
                            TextField("465", text: $emailViewModel.port)
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                            Text("Username: ")
                            Spacer()
                            TextField("max.musterman", text: $emailViewModel.username)
                                .disableAutocorrection(true)
                        }
                        
                        HStack {
                            Text("Password")
                            Spacer()
                            SecureField("*******", text: $emailViewModel.password)
                        }
                        
                        
                    }
                }
                Section(header: Text("Version")) {
                    Text("Version Number: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")")
                    Text("Build Number: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-")")
                }
            }
            .alert(isPresented: $showHalfWarningAlert, content: {
                Alert(title: Text("Achtung"),
                      message: Text("Das ausgewählte Halbjahr stimmt nicht mit den eingestellten Daten überein"),
                      primaryButton: Alert.Button.default(Text("Ok!"), action: { }),
                      secondaryButton: Alert.Button.cancel(Text("Abbrechen"), action: { self.selectedHalf = self.selectedHalf == .firstHalf ? .secondHalf : .firstHalf })
                )
            })
            .navigationBarTitle("Weiteres...", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button {
                        emailViewModel.save()
                        backupSettingsViewModel.save()
                        dismiss()
                    } label: {
                        Text("Schließen")
                    }
                    
                }
            }
            
        }
        .sheet(isPresented: $showingRestoreFromiCloud, content: {
            BackupRestoreView().environment(\.managedObjectContext, viewContext)
        })
        
        .if(backupType == .backup, transform: { view in
            view.fileExporter(isPresented: $showingBackup, document: BackupViewModel.getOneJsonFile(viewContext: viewContext), contentType: .json) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }

            }
        }).if(backupType == .export, transform: { view in
            view.fileExporter(isPresented: $showingExport, documents: BackupViewModel.getSingleCSVFiles(viewContext: viewContext), contentType: .commaSeparatedText) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
       
        .fileImporter(
            isPresented: $showingRestore,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFileURL: URL = try result.get().first else { return }
                if selectedFileURL.startAccessingSecurityScopedResource() {
                    let selectedFileData = try Data(contentsOf: selectedFileURL)
                    PersistenceController.deleteAllCourses(viewContext: viewContext)
                    PersistenceController.resetAllCoreData()
                    let _ = try! JSONDecoder().decode([Course].self, from: selectedFileData)
                    viewContext.saveCustom()
                    selectedFileURL.stopAccessingSecurityScopedResource()
                }
               
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    func halfCorrect() -> Bool {
        if selectedHalf == .firstHalf && Date() >= dateFirstHalf {
            return true
        } else if selectedHalf == .secondHalf && Date() >= dateSecondHalf {
            return true
        } else {
            return false
        }
    }
}


/*struct MoreActionsView_Previews: PreviewProvider {
 static var previews: some View {
 MoreActionsView()
 }
 }*/
