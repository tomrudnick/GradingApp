//
//  AddSingleGradeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.08.21.
//

import SwiftUI

struct AddSingleGradeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var student: Student
    
    @State private var gradeDate = Date()
    @State private var selectedGradeType = 0
    @State private var currentGrade = "0"
    @State private var showAddGradeSheet = false
    @State private var selectedGradeMultiplier = 2
    @State private var comment = ""
        
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                HStack {
                    ButtonCancelView()
                    Text("Add Grade for:\n\(student.firstName) \(student.lastName)")
                        .font(.headline)
                        .padding()
                   
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save")
                    })
                }
                
                Form {
                    Section {
                        HStack {
                            Text("Date")
                            DatePicker("", selection: $gradeDate, displayedComponents: [.date])
                        }
                        Picker(selection: $selectedGradeType, label: Text(""), content: {
                            Text("Oral").tag(0)
                            Text("Written").tag(1)
                        }).pickerStyle(SegmentedPickerStyle())
                        HStack {
                            Text("Grade")
                            Spacer()
                            Button(action: {
                                showAddGradeSheet.toggle()
                            }, label: {
                                Text(currentGrade)
                                    .padding()
                                    .frame(height: 25)
                                    .background(Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
                                    .cornerRadius(5.0)
                            })
                        }
                    }
                    Section(header: Text("Grade Multiplier") ) {
                        Picker(selection: $selectedGradeMultiplier, label: Text(""), content: {
                            Text(String(Grade.gradeMultiplier[0])).tag(0)
                            Text(String(Grade.gradeMultiplier[1])).tag(1)
                            Text(String(Grade.gradeMultiplier[2])).tag(2)
                            Text(String(Grade.gradeMultiplier[3])).tag(3)
                            Text(String(Grade.gradeMultiplier[4])).tag(4)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header: Text("Comment")) {
                        TextField("Comment...", text: $comment)
                    }
                }
            }
            
            BottomSheetView(isOpen: $showAddGradeSheet,
                            maxHeight: geometry.size.height * 0.5) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                    ForEach(Grade.lowerSchoolGrades, id: \.self) { grade in
                        Button(action: {
                            self.currentGrade = grade
                            self.showAddGradeSheet = false
                        }, label: {
                            Text(grade)
                                .foregroundColor(.white)
                                .font(.headline)
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        })
                        .padding(.all, 2.0)
                    }
                })
            }
        }
    }
    
    private func addGrade() {
        let multiplier = Grade.gradeMultiplier[selectedGradeMultiplier]
        let type = selectedGradeType == 0 ? GradeType.oral : GradeType.written
        
        let value = Grade.lowerSchoolGradesTranslate[currentGrade]!
        Grade.addGrade(value: value, date: gradeDate, half: HalfType.firstHalf, type: type, comment: comment, multiplier: multiplier, student: student, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddSingleGradeView_Previews: PreviewProvider {
    static var previewStudent : Student {
        let student = Student(context: PersistenceController.preview.container.viewContext)
        student.firstName = "Marit"
        student.lastName = "Abken"
        return student
    }
    static var previews: some View {
        AddSingleGradeView(student: previewStudent)
    }
}
