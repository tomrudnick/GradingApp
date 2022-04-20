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
    @State private var courseSubject: String
    
    @State var selectedAgeGroup: AgeGroup
    @State var selectedWeight: Float
    @State var selectedType: CourseType
    
    
    let subjects = ["Mathe", "Physik", "Chemie", "Informatik", "Seminarfach"]
    let viewTitle: String
    let saveHandler: (_ name: String, _ subject: String, _ oralWeight: Float, _ ageGroup: AgeGroup, _ type: CourseType) -> ()
    
    
    init(viewTitle: String, courseName: String = "", courseSubject: String = "", courseAgeGroup: AgeGroup = .lower, courseType: CourseType = .holeYear, courseOralWeight: Float = 50, saveHandler : @escaping (_ name: String, _ subject: String, _ oralWeight: Float, _ ageGroup: AgeGroup, _ type: CourseType) -> ()) {
        self.viewTitle = viewTitle
        self.saveHandler = saveHandler
        self._courseName = State(initialValue: courseName)
        self._courseSubject = State(initialValue: courseSubject)
        self._selectedAgeGroup = State(initialValue: courseAgeGroup)
        self._selectedWeight = State(initialValue: courseOralWeight)
        self._selectedType = State(initialValue: courseType)
    }
    var body: some View {
        NavigationView {
            Form {
                Section{
                    HStack{
                        NavigationLink {
                            SubjectListView(subject: $courseSubject)
                        } label: {
                            HStack{
                                Text("Fach")
                                Spacer()
                                Text(courseSubject)
                            }
                            
                        }
                        TextField("Kurs z.B. 11D", text: $courseName)
                            .frame(width: 100)
                    }
                    
                    Picker(selection: $selectedAgeGroup.animation(), label: Text(""), content: {
                        Text("Mittelstufe").tag(AgeGroup.lower)
                        Text("Oberstufe").tag(AgeGroup.upper)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    Picker(selection: $selectedType, label: Text(""), content: {
                        Text("1. Halbjahr").tag(CourseType.firstHalf)
                        Text("Ganzjährig").tag(CourseType.holeYear)
                        Text("2. Halbjahr").tag(CourseType.secondHalf)
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
                        .disabled(courseName.isEmpty || courseSubject.isEmpty)
                    Spacer()
                }
                
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text(viewTitle)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Abbrechen")
                    }
                }
            })
        }
    }
    
    func saveButtonPressed() {
        saveHandler(courseName, courseSubject, selectedWeight, selectedAgeGroup, selectedType)
        presentationMode.wrappedValue.dismiss()
    }
}

//struct SingleCourse_Previews: PreviewProvider {
//    @State static var kursName = ""
//    static var previews: some View {
//        SingleCourse(viewTitle: "Neuer Kurs") { (_, _, _  in }
//    }
//}
