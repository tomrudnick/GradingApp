//
//  EditSchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 12.09.22.
//

import SwiftUI

struct EditSchoolYearsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var oldSchoolYear: SchoolYear
    @State var newSchoolYearName: String = ""
    
    var body: some View {
        VStack {
            HStack{
                Text("Schuljahr umbenennen").font(.headline)
            Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                }
            }
            .padding()
            CustomTextfieldView(label: oldSchoolYear.name, input: $newSchoolYearName)
            
            CustomButtonView(label: "Übernehmen", action: self.saveButtonPressed , buttonColor: .accentColor)
                .disabled(newSchoolYearName.isEmpty)
                Divider()
        }
        Spacer()
    }
 
    func saveButtonPressed() {
        oldSchoolYear.updateSchoolYearName(name: newSchoolYearName, context: viewContext)
        if oldSchoolYear == appSettings.activeSchoolYear {
            appSettings.objectWillChange.send()
        }
        dismiss()
    }
}

//struct EditSchoolYearsView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditSchoolYearsView()
//    }
//}
