//
//  StudentTranscriptGradesFullYearView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 28.08.21.
//

import SwiftUI

struct StudentTranscriptGradesHalfYear: View {
    
    @ObservedObject var course: Course
    @Environment(\.currentHalfYear) private var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddGradeSheet: Bool = false
    @State private var selectedStudent: Student?
    @StateObject private var viewModel = TranscriptGradesHalfYearViewModel()
    
    
    var body: some View {
        ScrollViewReader { proxy in
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
                    List {
                        ForEach(viewModel.studentGrades) { studentGrade in
                            HStack {
                                StudentDetailListView(student: studentGrade.student)
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
                            }.onTapGesture {
                                selectedStudent = studentGrade.student
                                showAddGradeSheet = true
                                proxy.scrollTo(selectedStudent?.id, anchor: .top)
                            }.id(studentGrade.student.id)

                        }
                        Spacer().frame(height: geometry.size.height * 0.4)
                    }
                }
                BottomSheetView(isOpen: $showAddGradeSheet, maxHeight: geometry.size.height * 0.4) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                        ForEach(Grade.lowerSchoolTranscriptGrades, id: \.self) { grade in
                            Button(action: {
                                viewModel.setGrade(for: selectedStudent!, value: Grade.lowerSchoolGradesTranslate[grade]!)
                                selectedStudent = viewModel.course!.nextStudent(after: selectedStudent!)
                                scrollToNext(proxy: proxy)
                            }, label: {
                                BottomSheetViewButtonLabel(labelView: Text(grade))
                            })
                            .padding(.all, 2.0)
                        }
                        Button {
                            viewModel.setGrade(for: selectedStudent!, value: -1)
                            selectedStudent = viewModel.course!.nextStudent(after: selectedStudent!)
                            scrollToNext(proxy: proxy)
                        } label: {
                            BottomSheetViewButtonLabel(labelView: Text("-"))
                        }

                    })
                }.edgesIgnoringSafeArea(.bottom)
            }
        }
        .onAppear {
            viewModel.fetchData(course: course, halfYear: halfYear)
        }
    }
    
    func scrollToNext(proxy: ScrollViewProxy) {
        if selectedStudent == nil {
            self.showAddGradeSheet = false
        } else {
            proxy.scrollTo(selectedStudent?.id, anchor: .top)
        }
    }
    
    func save() {
        viewModel.save(viewContext: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
}


/*struct StudentTranscriptGradesFullYear_Previews: PreviewProvider {
    static var previews: some View {
        StudentTranscriptGradesFullYearView()
    }
}*/
