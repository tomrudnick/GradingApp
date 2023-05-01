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
    @Environment(\.dismiss) var dismiss
    @Environment(\.currentHalfYear) var halfYear
    
    @State private var gradeDate: Date = Date()
    @State private var selectedGradeType: Int = 0
    @State private var selectedGradeMultiplier: Int = 1
    @State private var comment: String = ""
    @State private var showAddGradeSheet: Bool = false
    @State private var selectedStudent: Student? = nil
    @State var studentGrade: [Student:Int] = [:]
    #if !targetEnvironment(macCatalyst)
    @FocusState private var focusTextField: Bool
    #endif
    
    let heightMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 0.3 : 0.5
    let scrollMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 0.4 : 0.2
    
    let minHeightForStudent = 70.0
    
    var body: some View {
        ScrollViewReader(content: { proxy in
            GeometryReader { geometry in
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
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
                                    ForEach(0..<Grade.gradeMultiplier.count, id: \.self) {index in
                                        Text(String(Grade.gradeMultiplier[index])).tag(index)
                                    }
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
                                if let student = studentGrade.first(where: { (key: Student, value: Int) in key == student }){
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
                                        
                                        
                                    }
                                    .border(student.key == selectedStudent ? Color.red : Color.clear)
                                    .frame(minHeight: minHeightForStudent)
                                    .onTapGesture {
                                        selectedStudent = student.key
                                        showAddGradeSheet = true
                                        withAnimation {
                                            perfectScroll(geo: geometry, scroll: proxy, student: selectedStudent)
                                        }
                                    }.id(student.key.id)
                                }
                            }
                            Spacer().frame(height: geometry.size.height)
                        }
                    }
                }

                BottomSheetMultipleGradesPicker(showAddGradeSheet: $showAddGradeSheet,
                                                selectedStudent: $selectedStudent,
                                                course: course,
                                                viewModel: viewModel,
                                                geometry: geometry,
                                                scrollProxy: proxy)
                { grade in
                    if let selectedStudent = selectedStudent {
                        studentGrade[selectedStudent] = grade
                        self.selectedStudent = course.nextStudent(after: selectedStudent)
                    }
                } scrollHandler: {
                    withAnimation {
                        perfectScroll(geo: geometry, scroll: proxy, student: selectedStudent)
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
            studentGrade = Dictionary(uniqueKeysWithValues: course.students.map({($0, -1)}))
            viewModel.setup(courseType: course.ageGroup, options: .normal)
        }
    }
    
    func perfectScroll(geo: GeometryProxy, scroll: ScrollViewProxy, student: Student?) {
        let indexOfStudent = course.studentsArr.firstIndex(where: {$0 == student})
        if let indexOfStudent {
            let difference = (geo.size.height * scrollMultiplier) - ((CGFloat(indexOfStudent) * minHeightForStudent) + minHeightForStudent)
            if difference > 0 {
                if let id = course.studentsArr.first?.id {
                    scroll.scrollTo(id, anchor: .top)
                }
            } else {
                let new_index = min(abs(Int(round(difference / minHeightForStudent))), course.studentsArr.count - 1)
                scroll.scrollTo(course.studentsArr[new_index].id, anchor: .top)
                //print("New_Index \(abs(Int(round(difference / 80.0))))")
            }
            print(geo.size.height * 0.5)
            print( CGFloat(indexOfStudent) * 80.0 + 80.0)
            print("Difference \(difference)")
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
        dismiss()
    }
}

/*struct AddMultipleGradesView_Previews: PreviewProvider {
 static var previews: some View {
 AddMultipleGradesView(course: Course()
 }
 }*/
