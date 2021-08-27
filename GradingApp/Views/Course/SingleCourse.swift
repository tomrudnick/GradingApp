//
//  SingleCourse.swift
//  GradingApp
//
//  Created by Tom Rudnick on 09.08.21.
//

import SwiftUI

struct SingleCourse: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var courseName: String
    @State var courseSubject: String
    @State var selectedAgeGroup: AgeGroup
    @State var selectedWeight: Float
    
    let viewTitle: String
    let saveHandler: (_ name: String, _ subject: String, _ oralWeight: Float, _ ageGroup: AgeGroup) -> ()
    
    
    init(viewTitle: String, courseName: String = "", courseSubject: String = "", courseAgeGroup: AgeGroup = .lower, courseOralWeight: Float = 50, saveHandler : @escaping (_ name: String, _ subject: String, _ oralWeight: Float, _ ageGroup: AgeGroup) -> ()) {
        self.viewTitle = viewTitle
        self.saveHandler = saveHandler
        self._courseName = State(initialValue: courseName)
        self._courseSubject = State(initialValue: courseSubject)
        self._selectedAgeGroup = State(initialValue: courseAgeGroup)
        self._selectedWeight = State(initialValue: courseOralWeight)
    }
    var body: some View {
        VStack {
            VStack {
                HStack{
                    Text(viewTitle).font(.headline)
                Spacer()
                    CancelButtonView(label: "Abbrechen")
                }
            }
            .padding()
            CustomTextfieldView(label: "Fach", input: $courseSubject)
            CustomTextfieldView(label: "Kursname z.B. 11D", input: $courseName)
            Picker(selection: $selectedAgeGroup.animation(), label: Text(""), content: {
                Text("Mittelstufe").tag(AgeGroup.lower)
                Text("Oberstufe").tag(AgeGroup.upper)
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            Text("Gewichtung")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            HStack{
                Text("mündlich: \(selectedWeight, specifier: "%.0f") %")
                Spacer()
                Text("schriftlich: \(100 - selectedWeight, specifier: "%.0f") %")
            }
            .padding(.horizontal)
            Slider(value: $selectedWeight, in: 0...100, step: 10)
                .accentColor(Color.gray)
                .padding()
            CustomButtonView(label: "Speichern", action: saveButtonPressed, buttonColor: .accentColor)
            .disabled(courseName.isEmpty)
            Spacer()
        }
    }
        
    func saveButtonPressed() {
        saveHandler(courseName, courseSubject, selectedWeight, selectedAgeGroup)
        presentationMode.wrappedValue.dismiss()
    }
}

//struct SingleCourse_Previews: PreviewProvider {
//    @State static var kursName = ""
//    static var previews: some View {
//        SingleCourse(viewTitle: "Neuer Kurs") { (_, _, _  in }
//    }
//}
