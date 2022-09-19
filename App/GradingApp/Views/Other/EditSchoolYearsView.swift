//
//  EditSchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 12.09.22.
//

import SwiftUI

struct EditSchoolYearsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var oldSchoolYear: SchoolYear
    @State var newSchoolYearName: String = ""
    @Binding var activeSchoolYear: String?
    
    
    var body: some View {
        VStack {
            HStack{
                Text("Schuljahr umbenennen").font(.headline)
            Spacer()
                Button {
                    self.presentationMode.wrappedValue.dismiss()
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
        if oldSchoolYear.name == activeSchoolYear {
            activeSchoolYear = newSchoolYearName
        }
        oldSchoolYear.updateSchoolYearName(name: newSchoolYearName, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
}

//struct EditSchoolYearsView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditSchoolYearsView()
//    }
//}
