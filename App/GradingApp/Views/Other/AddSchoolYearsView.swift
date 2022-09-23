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
    
    @State var schoolYear = "21/22"
    
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
            Picker("Neues Schuljahr auswählen", selection: $schoolYear) {
                           ForEach(generateSchoolYear(), id: \.self) { schoolYear in
                               Text("Schuljahr \(schoolYear)")
                           }
                       }
                       .pickerStyle(WheelPickerStyle())
            
            CustomButtonView(label: "Hinzufügen", action: self.saveButtonPressed , buttonColor: .accentColor)
                .disabled(schoolYear.isEmpty)
                Divider()
        }
        
    }
 
    func saveButtonPressed() {
        SchoolYear.addSchoolYear(name: schoolYear, context: viewContext)
        dismiss()
    }
    func generateSchoolYear()->[String]{
        var allSchoolYears = [String]()
        for i in 0 ... 49 {
            allSchoolYears.append(String(format: "%02d", i)+"/"+String(format: "%02d", i+1))

        }
        return allSchoolYears
    }
}

//struct AddSchoolYear_Previews: PreviewProvider {
//    static var previews: some View {
//        AddSchoolYear()
//    }
//}
