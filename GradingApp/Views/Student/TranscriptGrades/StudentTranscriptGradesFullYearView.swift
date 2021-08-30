//
//  StudentTranscriptGradesFullYearView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 28.08.21.
//

import SwiftUI

struct StudentTranscriptGradesFullYearView: View {
    
    @ObservedObject var course: Course
    @Environment(\.currentHalfYear) private var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var showAddGradeSheet: Bool = false
    
    var transcriptGradesFullYear : [FullYearTranscriptGrade?] {
        course.students.map { student  in
            student.transcriptGrade as? FullYearTranscriptGrade
        }
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                HStack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Abbrechen")
                    })
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("Speichern")
                    })
                }.padding()
                VStack {
                    ForEach(course.studentsArr) { student in
                        
                    }
                   
                }
                BottomSheetView(isOpen: $showAddGradeSheet, maxHeight: geometry.size.height * 0.4) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                        ForEach(Grade.lowerSchoolTranscriptGrades, id: \.self) { grade in
                            Button(action: {
                               
                            }, label: {
                                BottomSheetViewButtonLabel(labelView: Text(grade))
                            })
                            .padding(.all, 2.0)
                        }
                    })
                }.edgesIgnoringSafeArea(.bottom)
            }
            
        }
       
        
    }
}

struct StudentDetailTranscriptFullYearView: View {
    @ObservedObject var student: Student
    @Environment(\.currentHalfYear) private var halfYear
    
    var firstHalfGrade: Int {
        let transcriptGrade = student.transcriptGrade as? FullYearTranscriptGrade
        if let transcriptGrade = transcriptGrade {
            return Int(transcriptGrade.firstValue)
        } else {
            return -1
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(student.firstName)
                Spacer()
                Text("\(student.getRoundedGradeAverage()) (\(student.getGradeAverage()))")
                    .foregroundColor(Grade.getColor(points: student.totalGradeAverage()))
            }
            HStack {
                Text(student.lastName).bold()
                VStack(spacing: 0) {
                    Divider()
                }
            }.padding(.top, -8)
            HStack {
                Text("Mündlich: ")
                Text("\(student.getRoundedGradeAverage(.oral)) (\(student.getGradeAverage(.oral)))")
                    .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .oral)))
                Spacer()
            }
            HStack {
                Text("Schriftlich: ")
                Text("\(student.getRoundedGradeAverage(.written)) (\(student.getGradeAverage(.written)))")
                    .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .written)))
                Spacer()
            }
            if halfYear == .secondHalf {
                HStack {
                    Text("1. Halbjahr")
                    Text("\(Grade.convertGradePointsToGrades(value: firstHalfGrade))")
                        .foregroundColor(Grade.getColor(points: Double(firstHalfGrade)))
                }
            }
        }
    }

}

/*struct StudentTranscriptGradesFullYear_Previews: PreviewProvider {
    static var previews: some View {
        StudentTranscriptGradesFullYearView()
    }
}*/
