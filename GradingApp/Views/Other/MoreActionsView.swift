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


struct MoreActionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase
    @StateObject var viewModel = MoreActionsViewModel()
    @StateObject var emailViewModel = EmailAccountViewModel()
    @StateObject var backupSettingsViewModel: BackupSettingsViewModel
    @State var showHalfWarningAlert = false
    @State private var showingBackup = false
    @State private var showingRestore = false
    @State private var showingExport = false
    @ObservedObject var badgeViewModel: BadgeViewModel
    
    var onDelete: () -> ()
    
    init(badgeViewModel: BadgeViewModel, onDelete: @escaping () -> () = { }) {
        self.onDelete = onDelete
        self.badgeViewModel = badgeViewModel
        self._backupSettingsViewModel = StateObject(wrappedValue: BackupSettingsViewModel(badgeViewModel: badgeViewModel))
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Backup / Export")) {
                    Button {
                        self.showingBackup = true
                        viewModel.backupType = .backup
                    } label: {
                        ZStack {
                            Text("Backup")
                                
                            if self.badgeViewModel.badge != 0 {
                                Text("\(self.badgeViewModel.badge)").padding(6).background(Color.red).clipShape(Circle()).foregroundColor(.white).offset(x: 34, y: -6)
                            }
                        }
                        
                    }
                    Button {
                        self.showingExport = true
                        viewModel.backupType = .export
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
                    
                    DatePicker("Start 1. Halbjahr", selection: $viewModel.dateFirstHalf, displayedComponents: [.date])
                        .id(viewModel.dateFirstHalf) //Erzwingt den Datepicker einen rebuild des Views zu machen
                        .environment(\.locale, Locale.init(identifier: "de"))
                    
                    
                    DatePicker("Start 2. Halbjahr", selection: $viewModel.dateSecondHalf, displayedComponents: [.date])
                        .id(viewModel.dateSecondHalf) //Erzwingt den Datepicker einen rebuild des Views zu machen
                        .environment(\.locale, Locale.init(identifier: "de"))
                    
                    Picker(selection: $viewModel.selectedHalf, label: Text("")) {
                        Text("1. Halbjahr").tag(0)
                        Text("2. Halbjahr").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    
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
                      primaryButton: Alert.Button.default(Text("Ok!"),
                                                          action: {
                                                            save()
                                                          }),
                      secondaryButton: Alert.Button.cancel()
                )
            })
            .navigationBarTitle("Weiteres...", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button {
                        done()
                        emailViewModel.save()
                        backupSettingsViewModel.save()
                        backupSettingsViewModel.addNotifications()
                    } label: {
                        Text("Schließen")
                    }
                    
                }
            }
            
        }
        .onChange(of: scenePhase, perform: { newPhase in
            if newPhase == .active {
                self.badgeViewModel.updateBadge()
            }
        })
        .onAppear(perform: {
            self.badgeViewModel.updateBadge()
            backupSettingsViewModel.requestNotificationAuthorization()
        })
        .if(viewModel.backupType == .backup, transform: { view in
            view.fileExporter(isPresented: $showingBackup, document: viewModel.getOneJsonFile(viewContext: viewContext), contentType: .json) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                    backupSettingsViewModel.resetBadge()
                case .failure(let error):
                    print(error.localizedDescription)
                }

            }
        }).if(viewModel.backupType == .export, transform: { view in
            view.fileExporter(isPresented: $showingExport, documents: viewModel.getSingleCSVFiles(viewContext: viewContext), contentType: .commaSeparatedText) { result in
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
                    viewModel.deleteAllCourses(viewContext: viewContext)
                    let _ = try! JSONDecoder().decode([Course].self, from: selectedFileData)
                    viewContext.saveCustom()
                    selectedFileURL.stopAccessingSecurityScopedResource()
                }
               
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    
    func done() {
        if !viewModel.halfCorrect() {
            self.showHalfWarningAlert = true
        } else {
            save()
        }
    }
    
    func save() {
        viewModel.done()
        presentationMode.wrappedValue.dismiss()
    }
}


/*struct MoreActionsView_Previews: PreviewProvider {
 static var previews: some View {
 MoreActionsView()
 }
 }*/
