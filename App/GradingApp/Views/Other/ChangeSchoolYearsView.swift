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
    
    @State var schoolYearName: String = ""
    
    var schoolYearName_: String
    var title: String
    
    let saveHandler: (String) -> ()
    
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
            if existingSchoolYears.contains(where: {$0.name == schoolYearName }){
                CustomButtonView(label: "Schuljahr exisitiert bereits", action: self.saveButtonPressed, buttonColor: .accentColor)
                    .disabled(true)
            } else {
                CustomButtonView(label: "Übernehmen", action: self.saveButtonPressed , buttonColor: .accentColor)
            }
            Divider()
        }.onAppear {
            schoolYearName = schoolYearName_
        }
    }
    
    func saveButtonPressed() {
        saveHandler(schoolYearName)
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
