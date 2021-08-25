//
//  GradeAtDatesEditView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.08.21.
//

import SwiftUI

struct StudentGradesAtDate : View{
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var course: Course
    @State var date: Date
    @State var selectedGradeType: Int
    @State var studentGrades: [StudentGrade]
    @State var selectedGradeMultiplier: Int?
    @State var comment: String?
    @State private var showAddGradeSheet: Bool = false
    @State private var selectedStudent: Student?
    
    private var gradeType: GradeType {
        selectedGradeType == 0 ? .oral : .written
    }
    
    init(course: Course, date: Date, gradeType: GradeType) {
        self._date = State(initialValue: date)
        self._selectedGradeType = State(initialValue: gradeType == .oral ? 0 : 1)
        self.course = course
        self._studentGrades = State(initialValue: course.getGradesAtOneDate(for: date, gradeType: gradeType))
        
        let comments = self.studentGrades.filter({$0.grade != nil}).map({$0.grade!.comment!})
        
        if let comment = comments.first, comments.allSatisfy({$0 == comment}) {
            self._comment = State(initialValue: comment)
        } else {
            self._comment = State(initialValue: nil)
        }
        
        let multipliers = self.studentGrades.filter({$0.grade != nil}).map({$0.grade!.multiplier})
        if let multiplier = multipliers.first, multipliers.allSatisfy({$0 == multiplier }) {
            self._selectedGradeMultiplier = State(initialValue: Grade.gradeMultiplier.firstIndex(where: {$0 == multiplier}))
        } else {
            self._selectedGradeMultiplier = State(initialValue: nil)
        }
        
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                Form {
                    Section {
                        HStack {
                            DatePicker("Datum", selection: $date, displayedComponents: [.date])
                                .id(date) //Erzwingt den Datepicker einen rebuild des Views zu machen
                                .environment(\.locale, Locale.init(identifier: "de"))
                        }
                        Picker(selection: $selectedGradeType.animation(), label: Text(""), content: {
                            Text("Oral").tag(0)
                            Text("Written").tag(1)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    if selectedGradeType == 0 && selectedGradeMultiplier != nil {
                        Section(header: Text("Grade Multiplier") ) {
                            Picker(selection: $selectedGradeMultiplier ?? 1, label: Text(""), content: {
                                Text(String(Grade.gradeMultiplier[0])).tag(0)
                                Text(String(Grade.gradeMultiplier[1])).tag(1)
                                Text(String(Grade.gradeMultiplier[2])).tag(2)
                                Text(String(Grade.gradeMultiplier[3])).tag(3)
                            }).pickerStyle(SegmentedPickerStyle())
                        }.transition(.slide)
                    }
                    if comment != nil {
                        Section(header: Text("Comment")) {
                            TextField("Comment...", text: $comment ?? "")
                        }
                    }
                    Section(header: Text("Grades")) {
                        ForEach(studentGrades) { studentGrade in
                            HStack {
                                Text("\(studentGrade.student.firstName) \(studentGrade.student.lastName)")
                                Spacer()
                                Text(Grade.convertGradePointsToGrades(value: Int(studentGrade.grade?.value ?? -1)))
                                    .foregroundColor(Grade.getColor(points: Double(studentGrade.grade?.value ?? -1)))
                                    .padding()
                                    .frame(minWidth: 55)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                                    
                            }.if(studentGrade.student == selectedStudent) { view in
                                view.border(Color.red)
                            }
                            .onTapGesture {
                                selectedStudent = studentGrade.student
                                showAddGradeSheet = true
                                proxy.scrollTo(selectedStudent?.id, anchor: .top)
                            }.id(studentGrade.student.id)
                        }
                        CustomButtonView(label: "Löschen", action: {}, buttonColor: Color.red)

                        Spacer().frame(height: geometry.size.height * 0.4)
                    }
                }
                
                BottomSheetView(isOpen: $showAddGradeSheet, maxHeight: geometry.size.height * 0.5) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                        ForEach(Grade.lowerSchoolGrades, id: \.self) { grade in
                            Button(action: {
                                //studentGrade[selectedStudent!] = Grade.lowerSchoolGradesTranslate[grade]!
                                selectedStudent = course.nextStudent(after: selectedStudent!)
                                scrollToNext(proxy: proxy)
                            }, label: {
                                BottomSheetViewButtonLabel(labelView: Text(grade))
                            })
                            .padding(.all, 2.0)
                        }
                        Button {
                            selectedStudent = course.previousStudent(before: selectedStudent!)
                            scrollToNext(proxy: proxy)
                        } label: {
                            BottomSheetViewButtonLabel(labelView: Image(systemName: "arrow.up"))
                        }
                        
                        Button {
                            selectedStudent = course.nextStudent(after: selectedStudent!)
                            scrollToNext(proxy: proxy)
                        } label: {
                            BottomSheetViewButtonLabel(labelView: Image(systemName: "arrow.down"))
                        }

                    })
                }.edgesIgnoringSafeArea(.bottom)
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save")
                }

            }
        })
        .navigationTitle(Text(date.dateAsString()))
        
    }
    
    func scrollToNext(proxy: ScrollViewProxy) {
        if selectedStudent == nil {
            self.showAddGradeSheet = false
        } else {
            proxy.scrollTo(selectedStudent?.id, anchor: .top)
        }
    }
    
}

func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
