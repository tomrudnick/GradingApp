//
//  GradeAtDatesEditView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.08.21.
//

import SwiftUI

struct GradeAtDatesEditView : View{
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var editGradesPerDateVM: EditGradesPerDateViewModel
    
    @State private var showAddGradeSheet: Bool = false
    @State private var selectedStudent: Student?
    
    
    init(course: Course, studentGrades: [GradeStudent<Grade>]) {
        self._editGradesPerDateVM = StateObject(wrappedValue: EditGradesPerDateViewModel(studentGrades: studentGrades, course: course))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            GeometryReader { geometry in
                Form {
                    Section {
                        HStack {
                            DatePicker("Datum", selection: $editGradesPerDateVM.date, displayedComponents: [.date])
                                .id(editGradesPerDateVM.date) //Erzwingt den Datepicker einen rebuild des Views zu machen
                                .environment(\.locale, Locale.init(identifier: "de"))
                        }
                        Picker(selection: $editGradesPerDateVM.gradeTypeNumber.animation(), label: Text(""), content: {
                            Text("Oral").tag(0)
                            Text("Written").tag(1)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    if editGradesPerDateVM.gradeType == .oral && editGradesPerDateVM.gradeMultiplier != nil {
                        Section(header: Text("Grade Multiplier") ) {
                            Picker(selection: $editGradesPerDateVM.gradeMultiplierNumber, label: Text(""), content: {
                                Text(String(Grade.gradeMultiplier[0])).tag(0)
                                Text(String(Grade.gradeMultiplier[1])).tag(1)
                                Text(String(Grade.gradeMultiplier[2])).tag(2)
                                Text(String(Grade.gradeMultiplier[3])).tag(3)
                            }).pickerStyle(SegmentedPickerStyle())
                        }.transition(.slide)
                    }
                    if editGradesPerDateVM.comment != nil {
                        Section(header: Text("Comment")) {
                            TextField("Comment...", text: $editGradesPerDateVM.comment ?? "")
                        }
                    }
                    Section(header: Text("Grades")) {
                        ForEach(editGradesPerDateVM.studentGrades) { studentGrade in
                            HStack {
                                Text("\(studentGrade.student.firstName) \(studentGrade.student.lastName)")
                                Spacer()
                                Text(Grade.convertGradePointsToGrades(value: studentGrade.value))
                                    .foregroundColor(Grade.getColor(points: Double(studentGrade.value)))
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
                        CustomButtonView(label: "Löschen", action: {
                            editGradesPerDateVM.delete()
                            presentationMode.wrappedValue.dismiss()
                        }, buttonColor: Color.red)

                        Spacer().frame(height: geometry.size.height * 0.4)
                    }
                }
                
                BottomSheetView(isOpen: $showAddGradeSheet, maxHeight: geometry.size.height * 0.5) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                        ForEach(Grade.lowerSchoolGrades, id: \.self) { grade in
                            Button(action: {
                                editGradesPerDateVM.setGrade(for: selectedStudent!, value: Grade.lowerSchoolGradesTranslate[grade]!)
                                selectedStudent = editGradesPerDateVM.course.nextStudent(after: selectedStudent!)
                                scrollToNext(proxy: proxy)
                            }, label: {
                                BottomSheetViewButtonLabel(labelView: Text(grade))
                            })
                            .padding(.all, 2.0)
                        }
                        Button {
                            selectedStudent = editGradesPerDateVM.course.previousStudent(before: selectedStudent!)
                            scrollToNext(proxy: proxy)
                        } label: {
                            BottomSheetViewButtonLabel(labelView: Image(systemName: "arrow.up"))
                        }
                        
                        Button {
                            selectedStudent = editGradesPerDateVM.course.nextStudent(after: selectedStudent!)
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
                    editGradesPerDateVM.save(viewContext: viewContext)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save")
                }

            }
        })
        .navigationTitle(Text(editGradesPerDateVM.date.asString(format: "dd MMM")))
        
    }
    
    func scrollToNext(proxy: ScrollViewProxy) {
        if selectedStudent == nil {
            self.showAddGradeSheet = false
        } else {
            proxy.scrollTo(selectedStudent?.id, anchor: .top)
        }
    }
    
}
//Don't know how to extract this overload thing into another file at the moment....
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
