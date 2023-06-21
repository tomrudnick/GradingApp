//
//  GradeDetailView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//

import SwiftUI

//TODO: Split this View into two views (Written Grade and Oral Grade)
//TODO: This View could look a little bit better
struct GradeDetailView: View {
    
    enum WrittenGrade {
        case normal(Grade)
        case exam(Exam)
        
        var date: Date {
            switch self {
            case .exam(let exam): return exam.date
            case .normal(let grade): return grade.date ?? Date()
            }
        }
    }
    
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var student: Student
    
    @State var selectedExam: Exam? //In case you want to click on a specific exam
    
    var gradeType: GradeType
    
    var writtenGrades: [WrittenGrade] {
        let participatedExams: [WrittenGrade] = student.examParticipations
                                    .filter(\.participated)
                                    .compactMap(\.exam)
                                    .filter { $0.half == halfYear }
                                    .map { WrittenGrade.exam($0) }
        
        let writtenGrades = student.gradesArr
                                .filter { $0.type == .written && $0.half == halfYear }
                                .map { WrittenGrade.normal($0) }
        
        return (writtenGrades + participatedExams).sorted { $0.date < $1.date }
        
    }
    
    var oralGrades: [Grade] {
        student.gradesArr.filter { $0.type == gradeType && $0.half == halfYear }
    }
        
    
    var body: some View {
        List {
            if gradeType == .oral {
                oralGradeView
            } else {
                writtenGradeView
            }
        }
        .navigationTitle(Text("\(gradeType == .oral ? "Mündliche Noten" : "Schriftliche Noten") \(student.firstName) \(student.lastName)"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    var oralGradeView: some View {
        ForEach(oralGrades) { grade in
            standardGradeRow(grade: grade)
        }.onDelete { indexSet in
            Grade.delete(at: indexSet, for: student.gradesArr)
        }
    }
    
    
    
    var writtenGradeView: some View {
        ForEach(writtenGrades, id: \.date) { writtenGrade in
            switch writtenGrade {
            case .normal(let grade): standardGradeRow(grade: grade)
            case .exam(let exam): examGradeRow(exam: exam)
            }
        }
        .fullScreenCover(item: $selectedExam) { exam in
            if let course = exam.course {
                EditExamView(exam: exam, course: course)
                    .environmentObject(appSettings)
                    .environment(\.managedObjectContext, viewContext)
            } else {
                Text("Error")
            }
        }
    }
    
    @ViewBuilder func standardGradeRow(grade: Grade) -> some View {
        NavigationLink(value: Route.editGrade(student, grade)) {
            HStack {
                if grade.multiplier != 1.0 {
                    VStack {
                        Text(grade.toString())
                        Text(String(grade.multiplier)).font(.footnote)
                    }
                } else {
                    Text(grade.toString())
                }
                
                Spacer()
                Text(grade.dateAsString())
                Text(grade.comment ?? "")
            }
        }
    }
    
    @ViewBuilder func examGradeRow(exam: Exam) -> some View {
        Button {
            self.selectedExam = exam
        } label: {
            HStack {
                if exam.multiplier != 1.0 {
                    VStack {
                        Text(String(exam.getGrade(for: student)))
                        Text(String(exam.multiplier)).font(.footnote)
                    }
                } else {
                    Text(String(exam.getGrade(for: student)))
                }
                Spacer()
                Text(exam.date.asString(format: "dd MMM"))
                Text(exam.name)
                Image(systemName: "chevron.forward")
                    .foregroundColor(.secondary)
            }
        }.buttonStyle(.plain)
    }

    
}
