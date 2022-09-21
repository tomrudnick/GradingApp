//
//  StudentGradeListView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.08.21.
//

import SwiftUI
import Charts

struct StudentGradeListView: View {
    @ObservedObject var course: Course
    @Environment(\.currentHalfYear) var halfYear
    
    var body: some View {
        ScrollView {
            VStack {
                if #available(iOS 16.0, macCatalyst 16.0, *){
                    Chart {
                        BarMark(x: .value("Grade", "1"), y: .value("Count", course.getNumberOfGrades(for: 13...15, half: halfYear)))
                            .foregroundStyle(Color(red: 0.173, green: 0.894, blue: 0.455))
                        BarMark(x: .value("Grade", "2"), y: .value("Count", course.getNumberOfGrades(for: 10...12, half: halfYear)))
                            .foregroundStyle(Color(red: 0.803, green: 0.941, blue: 0.229))
                        BarMark(x: .value("Grade", "3"), y: .value("Count", course.getNumberOfGrades(for: 7...9, half: halfYear)))
                            .foregroundStyle(Color(red: 1.0, green: 0.898, blue: 0.0))
                        BarMark(x: .value("Grade", "4"), y: .value("Count", course.getNumberOfGrades(for: 4...6, half: halfYear)))
                            .foregroundStyle(Color(red: 1.0, green: 0.592, blue: 0.0))
                        BarMark(x: .value("Grade", "5"), y: .value("Count", course.getNumberOfGrades(for: 1...3, half: halfYear)))
                            .foregroundStyle(Color(red: 1.0, green: 0.224, blue: 0.141))
                        BarMark(x: .value("Grade", "6"), y: .value("Count", course.getNumberOfGrades(for: 0...0, half: halfYear)))
                            .foregroundStyle(Color(red: 0.737, green: 0.067, blue: 0.0))
                    }.padding()
                }
                
                ForEach(course.studentsArr) { student in
                    VStack {
                        HStack {
                            VStack {
                                StudentDetailViewTop(student: student)
                                HStack {
                                    StudentDetailView(student: student)
                                    if let transcriptGrade = student.transcriptGrade {
                                        StudentTranscriptGradeDetailView(transcriptGrade: transcriptGrade)
                                    }
                                }
                            }
                            
                            NavigationLink(value: Route.student(student)) {
                                Image(systemName: "exclamationmark.circle").font(.system(size: 20))
                            }.padding(.leading)
                        }.padding()
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 1.5)
                            .edgesIgnoringSafeArea(.horizontal)
                    }
                }
            }
        }
    }
}


/*struct CourseListGradeView_Previews: PreviewProvider {
    static var previews: some View {
        StudentGradeListView()
    }
}*/
