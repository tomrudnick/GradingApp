//
//  AddSchoolYear.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.09.22.
//

import SwiftUI
import CSV

struct AddSchoolYearsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State var schoolYear = ""
    
    var body: some View {
        VStack {
            HStack{
                Text("Neues Schuljahr").font(.headline)
            Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                }
            }
            .padding()
            CustomTextfieldView(label: "Schuljahr", input: $schoolYear)
            
            CustomButtonView(label: "Hinzufügen", action: self.saveButtonPressed , buttonColor: .accentColor)
                .disabled(schoolYear.isEmpty)
                Divider()
        }
        Spacer()
    }
 
    func saveButtonPressed() {
        SchoolYear.addSchoolYear(name: schoolYear, context: viewContext)
        dismiss()
    }
}

//struct AddSchoolYear_Previews: PreviewProvider {
//    static var previews: some View {
//        AddSchoolYear()
//    }
//}
