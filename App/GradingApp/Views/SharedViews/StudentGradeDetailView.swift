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

struct StudentDetailViewTop: StudentGradeDetailViewProtocol {
    @ObservedObject var student: Student
    @Environment(\.currentHalfYear) var halfYear
    
    init(student: Student) {
        self.student = student
    }
    
    var noGradeText: Text {
        Text("-").foregroundColor(Grade.getColor(points: -1.0))
    }
    var body: some View {
        VStack {
            HStack {
                Text(student.firstName)
                Spacer()
                if student.gradesExist(half: halfYear) {
                    Text("\(student.getRoundedGradeAverage(half: halfYear)) (\(student.getGradeAverage(half: halfYear)))")
                        .foregroundColor(Grade.getColor(points: student.totalGradeAverage(half: halfYear)))
                } else {
                    noGradeText
                }
                
            }
            HStack {
                Text(student.lastName).bold()
                VStack(spacing: 0) {
                    Divider()
                }
            }.padding(.top, -8)
        }
    }
}

struct StudentDetailView: StudentGradeDetailViewProtocol {
    @ObservedObject var student: Student
    @Environment(\.currentHalfYear) var halfYear
    
    init(student: Student) {
        self.student = student
    }
    
    var noGradeText: Text {
        Text("-").foregroundColor(Grade.getColor(points: -1.0))
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Mündlich: ")
                if student.gradesExist(.oral, half: halfYear) {
                    Text("\(student.getRoundedGradeAverage(.oral, half: halfYear)) (\(student.getGradeAverage(.oral, half: halfYear)))")
                        .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .oral, half: halfYear)))
                } else {
                    noGradeText
                }
                Spacer()
            }
            HStack {
                Text("Schriftlich: ")
                if student.gradesExist(.written, half: halfYear) {
                    Text("\(student.getRoundedGradeAverage(.written, half: halfYear)) (\(student.getGradeAverage(.written, half: halfYear)))")
                        .foregroundColor(Grade.getColor(points: student.gradeAverage(type: .written, half: halfYear)))
                } else {
                    noGradeText
                }
                Spacer()
            }
        }
    }
}


struct StudentTranscriptGradeDetailView: View {
    @ObservedObject var transcriptGrade: TranscriptGrade
    @Environment(\.currentHalfYear) var halfYear
    
    var body: some View {
        VStack {
            if halfYear == .firstHalf {
                if let transcriptGrade = transcriptGrade.getTranscriptGradeHalfValueString(half: .firstHalf), transcriptGrade != "-" {
                    HStack {
                        
                        Text("Zeugnis: ")
                        Text(transcriptGrade).foregroundColor(Grade.getColor(points: Double(self.transcriptGrade.getTranscriptGradeHalfValue(half: .firstHalf)!)))
                    }
                }
            } else if halfYear == .secondHalf {
                if let secondTranscriptGrade = transcriptGrade.getTranscriptGradeHalfValueString(half: .secondHalf), secondTranscriptGrade != "-" {
                    if transcriptGrade.student!.course!.type == CourseType.secondHalf {
                        HStack {
                            
                            Text("Zeugnis: ")
                            Text(secondTranscriptGrade).foregroundColor(Grade.getColor(points: Double(self.transcriptGrade.getTranscriptGradeHalfValue(half: .secondHalf)!)))
                        }
                        
                    } else {
                        HStack {
                            
                            Text("1. HJ: ")
                            Text(transcriptGrade.getTranscriptGradeHalfValueString(half: .firstHalf)).foregroundColor(Grade.getColor(points: Double(self.transcriptGrade.getTranscriptGradeHalfValue(half: .firstHalf)!)))
                        }
                        
                        HStack {
                            
                            Text("2. HJ: ")
                            Text(secondTranscriptGrade).foregroundColor(Grade.getColor(points: Double(self.transcriptGrade.getTranscriptGradeHalfValue(half: .secondHalf)!)))
                        }
                        
                        HStack {
                            
                            Text("Zeugnis: ")
                            Text(transcriptGrade.getTranscriptGradeValueString()).foregroundColor(Grade.getColor(points: Double(self.transcriptGrade.getCalculatedValue())))
                        }
                    }
                }
            }
        }
    }
}

