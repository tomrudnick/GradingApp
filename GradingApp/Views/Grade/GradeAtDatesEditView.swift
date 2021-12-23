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
    @Environment(\.currentHalfYear) private var halfYear
    
    @StateObject var editGradesPerDateVM: EditGradesPerDateViewModel
    @StateObject var gradePickerViewModel = GradePickerViewModel()
    
    @State private var showAddGradeSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var selectedStudent: Student?
    
    #if !targetEnvironment(macCatalyst)
    @FocusState private var focusTextField: Bool
    #endif
    
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
                    presentationMode.wrappedValue.dismiss()
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
                    editGradesPerDateVM.save(viewContext: viewContext)
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Speichern")
                }

            }
        })
        .navigationTitle(Text(editGradesPerDateVM.date.asString(format: "dd MMM")))
        
    }
    
}
//Don't know how to extract this overload thing into another file at the moment....
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}
