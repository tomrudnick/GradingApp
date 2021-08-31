//
//  MoreActionsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftUILib_DocumentPicker
import MobileCoreServices


struct MoreActionsView: View {
    
  
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MoreActionsViewModel()
    @State var showHalfWarningAlert = false
    @State private var showingExporter = false
    @State var showBackupPicker = false
    @State var showRestorePicker  = false
    
    var onRestore: () -> ()
    
    init(onRestore: @escaping () -> ()) {
        self.onRestore = onRestore
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Backup / Export")) {
                    Button {
                        self.showBackupPicker = true
                    } label: {
                        Text("Backup")
                    }
                    .documentPicker(
                          isPresented: $showBackupPicker,
                        documentTypes: ["public.folder"], onDocumentsPicked:  { urls in
                        viewModel.backup(url: urls.first!)
                        })
                    Button {
                        self.showingExporter = true
                    } label: {
                        Text("Export")
                    }
                }
                Section(header: Text("Import")) {
                    Button {
                        self.showRestorePicker = true
                    } label: {
                        Text("Import")
                    }
                    .documentPicker(
                          isPresented: $showRestorePicker,
                        documentTypes: [kUTTypeFolder as String], onDocumentsPicked:  { urls in
                            restore(url: urls.first!)
                        })
                }
                
                Section(header: Text("Temporary")) {
                    Button {
                        viewModel.deleteAllCourses(viewContext: viewContext)
                    } label: {
                        Text("Delete everything")
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
                
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
                    } label: {
                        Text("Schließen")
                    }

                }
                
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                    }

                }
            }
            
        }
        .fileExporter(isPresented: $showingExporter, documents: viewModel.getDocumentsSingleFiles(viewContext: viewContext), contentType: .commaSeparatedText) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
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
    
    func restore(url: URL) {
        viewModel.restore(url: url)
        onRestore()
    }
    
}


/*struct MoreActionsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreActionsView()
    }
}*/
