//
//  MoreActionsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import SwiftUI
import UniformTypeIdentifiers

struct MoreActionsView: View {
    
    @State private var showingExporter = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = MoreActionsViewModel()
     
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Backup / Import")) {
                    Button {
                        self.showingExporter = true
                    } label: {
                        Text("Backup")
                    }
                }
                
                Section(header: Text("Halbjahres Einstellung")) {
                    
                    DatePicker("Start 1. Halbjahr", selection: $viewModel.dateFirstHalf, displayedComponents: [.date])
                        .id(viewModel.dateFirstHalf) //Erzwingt den Datepicker einen rebuild des Views zu machen
                        .environment(\.locale, Locale.init(identifier: "de"))
                
                
                    DatePicker("Start 2. Halbjahr", selection: $viewModel.dateSecondHalf, displayedComponents: [.date])
                        .id(viewModel.dateSecondHalf) //Erzwingt den Datepicker einen rebuild des Views zu machen
                        .environment(\.locale, Locale.init(identifier: "de"))
                    
                    //Picker(selection: $viewModel.selectedHalf, label: <#T##_#>, content: <#T##() -> _#>)
                    
                }
            }.navigationBarTitle("Weiteres...", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                    Button {
                        viewModel.done()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Schließen")
                    }

                }
            }
            
        }
        .fileExporter(isPresented: $showingExporter, documents: viewModel.getDocuments(viewContext: viewContext), contentType: .commaSeparatedText) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    
}


struct MoreActionsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreActionsView()
    }
}
