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
    @FetchRequest(fetchRequest: SchoolYear.fetchAll(), animation: .default) private var existingSchoolYear: FetchedResults<SchoolYear>
    
    var title: String
    @State var schoolYearName = ""
    
    
    
    init(title: String, schoolYearName: String){
        self.title = title
        self.schoolYearName = schoolYearName
    }
    
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
            if existingSchoolYear.contains(where: { s in s.name == schoolYearName }){
                CustomButtonView(label: "Schuljahr exisitiert bereits", action: self.saveButtonPressed, buttonColor: .accentColor)
                    .disabled(true)
            } else {
                CustomButtonView(label: "Übernehmen", action: self.saveButtonPressed , buttonColor: .accentColor)
            }
            Divider()
        }
        //.onAppear{schoolYearName = oldSchoolYear.name}
        Spacer()
    }
    
    func saveButtonPressed() {
        if title == "Neues Schuljahr" {
            SchoolYear.addSchoolYear(name: schoolYearName, context: viewContext)
        }
        else {
            //schoolYear.updateSchoolYearName(name: schoolYearName, context: viewContext)
        }
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
