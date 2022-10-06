//
//  EditSchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 12.09.22.
//

import SwiftUI

struct EditSchoolYearsView: View {
    
    @ObservedObject var oldSchoolYear: SchoolYear
    
    var body: some View {
        //TODO: Pass the Save handler
        //In this Method you should update the attributes of the oldSchoolYear (line 12)
        //And also save it to the database
        ChangeSchoolYearsView(title: "Schuljahr umbennen")
        //it might look similar to this..
        /*ChangeSchoolYearsView(title: "Schuljahr umbenennen") { parameter in
            //This is the Body of the function
            //update oldSchoolYear accordingly using the parameter
        }*/
    }
}
    
    
    
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.dismiss) var dismiss
//    @FetchRequest(fetchRequest: SchoolYear.fetchAll(), animation: .default) private var existingSchoolYear: FetchedResults<SchoolYear>
//
//    @ObservedObject var oldSchoolYear: SchoolYear
//    @State var schoolYearName = ""
//
//    var body: some View {
//        VStack {
//            HStack{
//                Text("Schuljahr umbenennen").font(.headline)
//            Spacer()
//                Button {
//                    dismiss()
//                } label: {
//                    Text("Abbrechen")
//                }
//            }
//            .padding()
//            Picker("Neues Schuljahr auswählen", selection: $schoolYearName) {
//                           ForEach(generateSchoolYear(), id: \.self) { schoolYear in
//                               Text("Schuljahr \(schoolYear)")
//                           }
//                       }
//                       .pickerStyle(WheelPickerStyle())
//            if existingSchoolYear.contains(where: { s in s.name == schoolYearName }){
//                CustomButtonView(label: "Schuljahr exisitiert bereits", action: self.saveButtonPressed, buttonColor: .accentColor)
//                    .disabled(true)
//            } else {
//                CustomButtonView(label: "Übernehmen", action: self.saveButtonPressed , buttonColor: .accentColor)
//            }
//            Divider()
//        }
//        .onAppear{schoolYearName = oldSchoolYear.name}
//        Spacer()
//    }
//
//    func saveButtonPressed() {
//        oldSchoolYear.updateSchoolYearName(name: schoolYearName, context: viewContext)
//        dismiss()
//    }
//    func generateSchoolYear()->[String]{
//        var allSchoolYears = [String]()
//        for i in 0 ... 49 {
//            allSchoolYears.append(String(format: "%02d", i)+"/"+String(format: "%02d", i+1))
//
//        }
//        return allSchoolYears
//    }

//struct EditSchoolYearsView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditSchoolYearsView()
//    }
//}
