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
    
    var body: some View {
        VStack {
            Button("Reset to default") {
                exam.resetToDefaultGradeSchema()
            }
            Text("Anzahl an Durchgefallenen: \(exam.getNumberOfGrades(for: exam.failedGrades))")
            Chart (exam.getChartData()){ grade in
                BarMark(
                    x: .value("Grade", grade.label),
                    y: .value("Anzahl", Int(grade.value))
                )
            }
            GraphViewControllerReprestable(exam: exam)
        }.navigationTitle("Noten Schema")
    }
}

