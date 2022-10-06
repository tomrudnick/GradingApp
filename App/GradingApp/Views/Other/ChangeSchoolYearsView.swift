//
//  ChangeSchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 06.10.22.
//

import SwiftUI

struct ChangeSchoolYearsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(fetchRequest: SchoolYear.fetchAll(), animation: .default)
    private var existingSchoolYears: FetchedResults<SchoolYear>
    
    @State var schoolYearName = "21/22"
    var title: String
    
    //TODO: Add the decleration of the function it should probably have one argument and no return values
    //This method should be called when the save button is pressed
    
    var body: some View {
        VStack {
            HStack{
                Text(title).font(.headline)
            Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                }
            }
            .padding()
            Picker("Neues Schuljahr auswählen", selection: $schoolYearName) {
                           ForEach(generateSchoolYear(), id: \.self) { schoolYear in
                               Text("Schuljahr \(schoolYear)")
                           }
                       }
                       .pickerStyle(WheelPickerStyle())
            if existingSchoolYears.contains(where: { s in s.name == schoolYearName }){
                CustomButtonView(label: "Schuljahr exisitiert bereits", action: self.saveButtonPressed, buttonColor: .accentColor)
                    .disabled(true)
            } else {
                CustomButtonView(label: "Übernehmen", action: self.saveButtonPressed , buttonColor: .accentColor)
            }
            Divider()
        }
    }
    
    func saveButtonPressed() {
        //TODO: Call Save handler
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

//struct ChangeSchoolYearsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeSchoolYearsView()
//    }
//}
