//
//  GradeAtDatesEditView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.08.21.
//

import SwiftUI

struct GradeAtDatesEditView : View{
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.currentHalfYear) private var halfYear
    
    @StateObject var editGradesPerDateVM: EditGradesPerDateViewModel
    @StateObject var gradePickerViewModel = GradePickerViewModel()
    
    @State private var showAddGradeSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var selectedStudent: Student?
    
    #if !targetEnvironment(macCatalyst)
    @FocusState private var focusTextField: Bool
    #endif
    
    let heightMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 0.3 : 0.5
    let scrollMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 0.4 : 0.2
    
    let minHeightForStudent = 70.0
    
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
                            Text("Mündlich").tag(0)
                            Text("Schriftlich").tag(1)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    if editGradesPerDateVM.gradeType == .oral && editGradesPerDateVM.gradeMultiplier != nil {
                        Section(header: Text("Gewichtung") ) {
                            Picker(selection: $editGradesPerDateVM.gradeMultiplierNumber, label: Text(""), content: {
                                ForEach(0..<Grade.gradeMultiplier.count, id: \.self) {index in
                                    Text(String(Grade.gradeMultiplier[index])).tag(index)
                                }
                            }).pickerStyle(SegmentedPickerStyle())
                        }.transition(.slide)
                    }
                    if editGradesPerDateVM.comment != nil {
                        Section(header: Text("Kommentar")) {
                            TextField("LZK...", text: $editGradesPerDateVM.comment ?? "")
                                #if !targetEnvironment(macCatalyst)
                                .focused($focusTextField)
                                .onChange(of: focusTextField) { value in
                                    if value {
                                        showAddGradeSheet = false
                                    }
                                }
                                #endif
                        }
                    }
                    Section(header: Text("Noten")) {
                        ForEach(editGradesPerDateVM.studentGrades) { studentGrade in
                            HStack {
                                Text("\(studentGrade.student.firstName) \(studentGrade.student.lastName)")
                                Text("(\(studentGrade.student.gradeCount(editGradesPerDateVM.gradeType, half: halfYear)))")
                                    .font(.footnote)
                                Spacer()
                                Text(gradePickerViewModel.translateToString(studentGrade.value))
                                    .foregroundColor(Grade.getColor(points: Double(studentGrade.value)))
                                    .padding()
                                    .frame(minWidth: 55)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                                    
                            }
                            .border(studentGrade.student == selectedStudent ? Color.red : Color.clear)
                            .frame(minHeight: minHeightForStudent)
                            .onTapGesture {
                                selectedStudent = studentGrade.student
                                showAddGradeSheet = true
                                withAnimation {
                                    perfectScroll(geo: geometry, scroll: proxy, student: selectedStudent)
                                }
                            }.id(studentGrade.student.id)
                        }
                        CustomButtonView(label: "Löschen", action: {
                            self.showDeleteAlert = true
                        }, buttonColor: Color.red)

                        Spacer().frame(height: geometry.size.height * 0.5)
                    }
                }
                BottomSheetMultipleGradesPicker(showAddGradeSheet: $showAddGradeSheet, selectedStudent: $selectedStudent, course: editGradesPerDateVM.course, viewModel: gradePickerViewModel, geometry: geometry, scrollProxy: proxy) { grade in
                    if let selectedStudent = selectedStudent {
                        editGradesPerDateVM.setGrade(for: selectedStudent, value: grade)
                        self.selectedStudent = editGradesPerDateVM.course.nextStudent(after: selectedStudent)
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
        }
        .alert(isPresented: $showDeleteAlert, content: {
            Alert(
                title: Text("Achtung!"),
                message: Text("Möchten sie diese Noten wirklich löschen?"),
                primaryButton: .destructive(Text("Ja")) {
                    editGradesPerDateVM.delete(viewContext: viewContext)
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        })
        .onAppear {
            gradePickerViewModel.setup(courseType: editGradesPerDateVM.course.ageGroup, options: .normal)
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editGradesPerDateVM.save(viewContext: viewContext, halfYear: halfYear)
                    dismiss()
                } label: {
                    Text("Speichern")
                }

            }
        })
        .navigationTitle(Text(editGradesPerDateVM.date.asString(format: "dd MMM")))
        
    }
    
    
    func perfectScroll(geo: GeometryProxy, scroll: ScrollViewProxy, student: Student?) {
        let indexOfStudent = editGradesPerDateVM.studentGrades.firstIndex { gradeStudent in
            gradeStudent.student == student
        }
        if let indexOfStudent {
            let difference = (geo.size.height * scrollMultiplier) - ((CGFloat(indexOfStudent) * minHeightForStudent) + minHeightForStudent)
            if difference > 0 {
                if let id = editGradesPerDateVM.studentGrades.first?.id {
                    scroll.scrollTo(id, anchor: .top)
                }
            } else {
                let new_index = min(abs(Int(round(difference / minHeightForStudent))), editGradesPerDateVM.studentGrades.count - 1)
                scroll.scrollTo(editGradesPerDateVM.studentGrades[new_index].student.id, anchor: .top)
                //print("New_Index \(abs(Int(round(difference / 80.0))))")
            }
            print(geo.size.height * 0.5)
            print( CGFloat(indexOfStudent) * 80.0 + 80.0)
            print("Difference \(difference)")
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
