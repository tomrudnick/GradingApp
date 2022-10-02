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
    
    let heightMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 0.3 : 0.5
    let scrollMultiplier = UIDevice.current.userInterfaceIdiom == .pad ? 0.35 : 0.2
    
    let minHeightForStudent = 80.0
    
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
                        Spacer().frame(height: geometry.size.height * 0.5)
                    }

                }
                BottomSheetMultipleGradesPicker(showAddGradeSheet: $showAddGradeSheet, selectedStudent: $selectedStudent, course: course, viewModel: gradePickerViewModel, geometry: geometry, scrollProxy: proxy) { grade in
                    if let selectedStudent = selectedStudent {
                        viewModel.setGrade(for: selectedStudent, value: grade)
                        self.selectedStudent = viewModel.course!.nextStudent(after: selectedStudent)
                    }
                    
                } scrollHandler: {
                    withAnimation {
                        perfectScroll(geo: geometry, scroll: proxy, student: selectedStudent)
                    }
                }
            }
        }.onAppear {
            gradePickerViewModel.setup(courseType: course.ageGroup, options: .transcript)
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
        viewModel.save(viewContext: viewContext)
        dismiss()
    }
}





/*struct StudentTranscriptGradesView_Previews: PreviewProvider {
    static var previews: some View {
        StudentTranscriptGradesView()
    }
}*/
