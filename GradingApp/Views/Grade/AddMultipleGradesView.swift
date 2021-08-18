//
//  AddMultipleGradesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 18.08.21.
//

import SwiftUI

struct AddMultipleGradesView: View {
    
    @ObservedObject var course: Course
    
    @Environment(\.presentationMode) var presentationMode
    @State private var gradeDate: Date = Date()
    @State private var selectedGradeType: Int = 0
    @State private var selectedGradeMultiplier: Int = 1
    @State private var comment: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: {
                        
                    }, label: {
                        Text("Abbrechen")
                    })
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Speichern")
                    })
                }
                Form {
                    Section {
                        HStack {
                            DatePicker("Datum", selection: $gradeDate, displayedComponents: [.date])
                                .id(gradeDate) //Erzwingt den Datepicker einen rebuild des Views zu machen
                                .environment(\.locale, Locale.init(identifier: "de"))
                        }
                        Picker(selection: $selectedGradeType, label: Text(""), content: {
                            Text("Oral").tag(0)
                            Text("Written").tag(1)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    Section(header: Text("Grade Multiplier") ) {
                        Picker(selection: $selectedGradeMultiplier, label: Text(""), content: {
                            Text(String(Grade.gradeMultiplier[0])).tag(0)
                            Text(String(Grade.gradeMultiplier[1])).tag(1)
                            Text(String(Grade.gradeMultiplier[2])).tag(2)
                            Text(String(Grade.gradeMultiplier[3])).tag(3)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header: Text("Comment")) {
                        TextField("Comment...", text: $comment)
                    }
                    
                    Section(header: Text("Grades")) {
                        List {
                            ForEach(course.studentsArr) { student in
                                HStack {
                                    Text("\(student.firstName) \(student.lastName)")
                                    Spacer()
                                    Text("-")
                                        .padding()
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .background(Color.accentColor)
                                        .cornerRadius(10)
                                        
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

/*struct AddMultipleGradesView_Previews: PreviewProvider {
    static var previews: some View {
        AddMultipleGradesView(course: Course()
    }
}*/
