//
//  StudentGradeDetailView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.09.21.
//

import SwiftUI

protocol StudentGradeDetailViewProtocol : View {
    init(student: Student)
}

struct StudentTranscriptDetailView: StudentGradeDetailViewProtocol{
    @ObservedObject var student: Student
    
    var body: some View {
        VStack {
            HStack {
                Text(student.firstName)
                Spacer()
                if student.transcriptGrade == nil {
                    Text("Berechnet: -")
                        .foregroundColor(Grade.getColor(points: -1.0))
                } else {
                    Text("Berechnet: \(student.transcriptGrade!.getCalculatedValueString())")
                        .foregroundColor(Grade.getColor(points: student.transcriptGrade!.getCalculatedValue()))
                }
                
            }
            HStack {
                Text(student.lastName).bold()
                VStack(spacing: 0) {
                    Divider()
                }
            }.padding(.top, -8)
            HStack {
                Text("1. Halbjahr: ")
                Text(student.transcriptGrade?.getTranscriptGradeHalfValueString(half: .firstHalf) ?? "-")
                    .foregroundColor(Grade.getColor(points: Double(student.transcriptGrade?.getTranscriptGradeHalfValue(half: .firstHalf) ?? -1)))
                Spacer()
            }
            HStack {
                Text("2. Halbjahr: ")
                Text(student.transcriptGrade?.getTranscriptGradeHalfValueString(half: .secondHalf) ?? "-")
                    .foregroundColor(Grade.getColor(points: Double(student.transcriptGrade?.getTranscriptGradeHalfValue(half: .secondHalf) ?? -1)))
                Spacer()
            }
        }
    }
}

struct StudentDetailView: StudentGradeDetailViewProtocol {
    @ObservedObject var student: Student
    @Environment(\.currentHalfYear) var halfYear
    
    init(student: Student) {
        self.student = student
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(student.firstName)
                Spacer()
                Text("\(student.getRoundedGradeAverage(half: halfYear)) (\(student.getGradeAverage(half: halfYear)))")
                    .foregroundColor(Grade.getColor(points: student.totalGradeAverage(half: halfYear)))
            }
            HStack {
                Text(student.lastName).bold()
                VStack(spacing: 0) {
                    Divider()
                }
            }.padding(.top, -8)
            HStack {
                Text("Mündlich: ")
                Text("\(student.getRoundedGradeAverage(.oral, half: halfYear)) (\(student.getGradeAverage(.oral, half: halfYear)))")
                    .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .oral, half: halfYear)))
                Spacer()
            }
            HStack {
                Text("Schriftlich: ")
                Text("\(student.getRoundedGradeAverage(.written, half: halfYear)) (\(student.getGradeAverage(.written, half: halfYear)))")
                    .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .written, half: halfYear)))
                Spacer()
            }
        }
    }
}

