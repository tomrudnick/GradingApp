//
//  ExamGradingSchemeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import SwiftUI
import Charts

struct ExamGradingSchemeView: View {
    @ObservedObject var exam: Exam
    var percentageOfFailed: String {
        String(format: "%.2f", exam.getPercentageOfFailed()) + " %"
    }
    
    var body: some View {
        VStack {
            Button("Reset to default") {
                exam.resetToDefaultGradeSchema()
            }
            Text("Anzahl an Durchgefallenen: \(exam.getNumberOfGrades(for: exam.failedGrades)) (\(percentageOfFailed))"  )
            HStack {
                VStack {
                    Chart (exam.getChartData().reversed()){ grade in
                        BarMark(
                            x: .value("Grade", grade.label),
                            y: .value("Anzahl", Int(grade.value))
                        )
                    }
                }
                .padding([.leading, .top, .bottom])
                
                VStack {
                    List {
                        HStack {
                            Text("Note").bold().foregroundColor(Color.accentColor)
                            Spacer()
                            Text("Anzahl").bold().foregroundColor(Color.accentColor)
                        }
                        ForEach(exam.mapGradesToNumberOfOccurences.reversed(), id: \.id) { gradeNumber in
                            HStack {
                                Text(gradeNumber.grade)
                                Spacer()
                                Text(gradeNumber.number).padding(.trailing)
                            }
                        }
                    }
                }.frame(minHeight: 400)
               
            }.fixedSize(horizontal: false, vertical: true)
                
            
            GraphViewControllerReprestable(exam: exam)
        }.navigationTitle("Noten Schema")
    }
}

