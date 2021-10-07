//
//  AddMultipleGradesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 18.08.21.
//

import SwiftUI

struct AddMultipleGradesView: View {
    
    @StateObject var viewModel = GradePickerViewModel()
    
    @ObservedObject var course: Course
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.currentHalfYear) var halfYear
    
    @State private var gradeDate: Date = Date()
    @State private var selectedGradeType: Int = 0
    @State private var selectedGradeMultiplier: Int = 1
    @State private var comment: String = ""
    @State private var showAddGradeSheet: Bool = false
    @State private var selectedStudent: Student? = nil
    @Binding var studentGrade: [Student:Int]
    #if !targetEnvironment(macCatalyst)
    @FocusState private var focusTextField: Bool
    #endif
    
    
    var body: some View {
        ScrollViewReader(content: { proxy in
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Abbrechen")
                        })
                        Spacer()
                        Button(action: {
                            save()
                        }, label: {
                            Text("Speichern")
                        })
                    }.padding()
                    Form {
                        Section {
                            HStack {
                                DatePicker("Datum", selection: $gradeDate, displayedComponents: [.date])
                                    .id(gradeDate) //Erzwingt den Datepicker einen rebuild des Views zu machen
                                    .environment(\.locale, Locale.init(identifier: "de"))
                            }
                            Picker(selection: $selectedGradeType.animation(), label: Text(""), content: {
                                Text("Mündlich").tag(0)
                                Text("Schriftlich").tag(1)
                            }).pickerStyle(SegmentedPickerStyle())
                        }
                        if selectedGradeType == 0 {
                            Section(header: Text("Gewichtung") ) {
                                Picker(selection: $selectedGradeMultiplier, label: Text(""), content: {
                                    Text(String(Grade.gradeMultiplier[0])).tag(0)
                                    Text(String(Grade.gradeMultiplier[1])).tag(1)
                                    Text(String(Grade.gradeMultiplier[2])).tag(2)
                                    Text(String(Grade.gradeMultiplier[3])).tag(3)
                                }).pickerStyle(SegmentedPickerStyle())
                            }.transition(.slide)
                        }
                        Section(header: Text("Kommentar")) {
                            TextField("LZK...", text: $comment)
                                #if !targetEnvironment(macCatalyst)
                                .focused($focusTextField)
                                .onChange(of: focusTextField) { value in
                                    if value {
                                        showAddGradeSheet = false
                                    }
                                }
                                #endif
                        }
                            
                        Section(header: Text("Noten")) {
                            ForEach(course.studentsArr) { student in
                                if let student = studentGrade.first { (key: Student, value: Int) in key == student }{
                                    HStack {
                                        Text("\(student.key.firstName) \(student.key.lastName)")
                                        Text("(\(student.key.gradeCount(selectedGradeType == 0 ? GradeType.oral : GradeType.written, half: halfYear)))")
                                            .font(.footnote)
                                        Spacer()
                                        Text(viewModel.translateToString(student.value))
                                            .padding()
                                            .frame(minWidth: 55)
                                            .foregroundColor(.white)
                                            .font(.headline)
                                            .background(Color.accentColor)
                                            .cornerRadius(10)
                                        
                                        
                                    }.if(student.key == selectedStudent, transform: { view in
                                        view.border(Color.red)
                                    })
                                    .onTapGesture {
                                        selectedStudent = student.key
                                        showAddGradeSheet = true
                                        proxy.scrollTo(selectedStudent?.id, anchor: .top)
                                    }.id(student.key.id)
                                }
                            }
                            Spacer().frame(height: geometry.size.height * 0.5)
                        }
                       
                    }
                }
                BottomSheetMultipleGradesPicker(showAddGradeSheet: $showAddGradeSheet,
                                           selectedStudent: $selectedStudent,
                                           course: course,
                                           viewModel: viewModel,
                                           geometry: geometry,
                                           scrollProxy: proxy) { grade in
                    if let selectedStudent = selectedStudent {
                        studentGrade[selectedStudent] = grade
                        self.selectedStudent = course.nextStudent(after: selectedStudent)
                    }
                }
                #if !targetEnvironment(macCatalyst)
               .onChange(of: showAddGradeSheet) { value in
                    if value {
                        focusTextField = false
                    }
                }
                #endif
            }
        })
        .onAppear {
            viewModel.setup(courseType: course.ageGroup, options: .normal)
        }
    }
    
    
    func save() {
        let multiplier = Grade.gradeMultiplier[selectedGradeMultiplier]
        let type = selectedGradeType == 0 ? GradeType.oral : GradeType.written
        for (key, value) in studentGrade {
            if value != -1 {
                let multiplier = type == GradeType.oral ? multiplier : 1.0
                Grade.addGrade(value: value, date: gradeDate, half: halfYear, type: type, comment: comment, multiplier: multiplier, student: key, context: viewContext)
            }
        }
        studentGrade.removeAll()
        presentationMode.wrappedValue.dismiss()
    }
}

/*struct AddMultipleGradesView_Previews: PreviewProvider {
 static var previews: some View {
 AddMultipleGradesView(course: Course()
 }
 }*/
