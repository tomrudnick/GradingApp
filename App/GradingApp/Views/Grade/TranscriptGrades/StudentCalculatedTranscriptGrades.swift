//
//  StudentCalculatedTranscriptGrades.swift
//  GradingApp
//
//  Created by Tom Rudnick on 19.04.22.
//

import SwiftUI

struct StudentCalculatedTranscriptGrades: View {
    
    @ObservedObject var course: Course
    @Environment(\.dismiss) var dismiss
    
    var noGradeText: Text {
        Text("-").foregroundColor(Grade.getColor(points: -1.0))
    }
    
    func calculateGrade(student: Student) -> Text {
        if let transcriptGrade = student.transcriptGrade?.getTranscriptGradeHalfValue(half: .firstHalf),
           transcriptGrade != -1 {
            if student.gradesExist(half: .secondHalf) {
                let secondHalfAverage = student.totalGradeAverage(half: .secondHalf)
                let average = (Double(transcriptGrade) + secondHalfAverage) / 2.0
                let roundedAverage = roundDecimal(points: average, ageGroup: student.course?.ageGroup)
                return Text("\(Grade.toString(ageGroup: student.course?.ageGroup, value: Int32(round(average)))) (\(roundedAverage))")
                    .foregroundColor(Grade.getColor(points: average))
            } else {
                return Text(student.transcriptGrade!.getTranscriptGradeHalfValueString(half: .firstHalf))
                    .foregroundColor(Grade.getColor(points: Double(transcriptGrade)))
            }
        } else {
            let roundedGrade = roundDecimal(points: student.totalGradeAverage(half: .secondHalf), ageGroup: student.course?.ageGroup)
            return Text("\(student.getRoundedGradeAverage(half: .secondHalf)) (\(roundedGrade))")
                .foregroundColor(Grade.getColor(points: student.totalGradeAverage(half: .secondHalf)))
        }
    }
    
    func roundDecimal(points: Double, ageGroup: AgeGroup?) -> String {
        switch ageGroup {
        case .lower:
            return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: points))
        case .upper:
            return String(format: "%.1f", points)
        case .none:
            return "-"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Schließen")
                }
                Spacer()
            }.padding()
            List {
                ForEach(course.studentsArr) { student in
                    VStack(alignment: .leading) {
                        Text(student.firstName)
                        Text(student.lastName).bold()
                        HStack {
                            Text("1. Halbjahr: ")
                            Text(student.transcriptGrade?.getTranscriptGradeHalfValueString(half: .firstHalf) ?? "-")
                                .foregroundColor(Grade.getColor(points: Double(student.transcriptGrade?.getTranscriptGradeHalfValue(half: .firstHalf) ?? -1)))
                            Spacer()
                            Text("Berechnet: ").bold()
                            
                        }
                        HStack {
                            Text("2. Halbjahr: ")
                            if student.gradesExist(half: .secondHalf) {
                                Text("\(student.getRoundedGradeAverage(half: .secondHalf)) (\(student.getGradeAverage(half: .secondHalf)))")
                                    .foregroundColor(Grade.getColor(points: student.totalGradeAverage(half: .secondHalf)))
                            } else {
                                noGradeText
                            }
                            Spacer()
                            calculateGrade(student: student)
                            
                        }
                        
                    }
                }
            }
        }
    }
}

