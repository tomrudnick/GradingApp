//
//  StudentTranscriptGradesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 01.09.21.
//

import SwiftUI
/**
    This View is used to init the TranscriptGrades for a half Year or a full Year
    The View has two generic types:
        1. Model which is the viewModel that conforms to TranscriptGradesViewModelProtocol
        2. DetailView which is the way the Rows are displayed of the ListView and therefore how every student is displayed. It conforms to the StudentGradeDetailViewProtocol
 */
struct StudentTranscriptGradesView<Model, DetailView>: View where Model: TranscriptGradesViewModelProtocol, DetailView: View {
    
    @StateObject var gradePickerViewModel = GradePickerViewModel()
    
    @Environment(\.currentHalfYear) private var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State private var showAddGradeSheet: Bool = false
    @State private var selectedStudent: Student?
    
    @ObservedObject var viewModel : Model
    @ObservedObject var course: Course
    
    let detailStudentView: (_ student: Student) -> DetailView
    
    init(course: Course, viewModel: Model, @ViewBuilder detailView: @escaping (_ student: Student) -> DetailView) {
        self.course = course
        self.viewModel = viewModel
        self.detailStudentView = detailView
    }
    
    var body: some View {
        ScrollViewReader { proxy in
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
                    List {
                        ForEach(viewModel.studentGrades) { studentGrade in
                            HStack {
                                detailStudentView(studentGrade.student)
                                Spacer()
                                Text(gradePickerViewModel.translateToString(studentGrade.value))
                                    .foregroundColor(Grade.getColor(points: Double(studentGrade.value)))
                                    .padding()
                                    .frame(minWidth: 55)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                                    .shadow(radius: 5.0)
                            }.if(studentGrade.student == selectedStudent) { view in
                                view.border(Color.red)
                            }.onTapGesture {
                                selectedStudent = studentGrade.student
                                showAddGradeSheet = true
                                proxy.scrollTo(selectedStudent?.id, anchor: .top)
                            }.id(studentGrade.student.id)
                            
                        }
                        Spacer().frame(height: geometry.size.height * 0.5)
                    }

                }
                BottomSheetMultipleGradesPicker(showAddGradeSheet: $showAddGradeSheet, selectedStudent: $selectedStudent, course: course, viewModel: gradePickerViewModel, geometry: geometry, scrollProxy: proxy) { grade in
                    if let selectedStudent = selectedStudent {
                        viewModel.setGrade(for: selectedStudent, value: grade)
                        self.selectedStudent = viewModel.course!.nextStudent(after: selectedStudent)
                    }
                    
                }
            }
        }.onAppear {
            gradePickerViewModel.setup(courseType: course.ageGroup, options: .transcript)
        }
    }
    func save() {
        viewModel.save(viewContext: viewContext)
        dismiss()
    }
}





/*struct StudentTranscriptGradesView_Previews: PreviewProvider {
    static var previews: some View {
        StudentTranscriptGradesView()
    }
}*/
