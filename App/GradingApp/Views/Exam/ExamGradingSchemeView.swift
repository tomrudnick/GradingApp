//
//  ExamGradingSchemeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import SwiftUI
import Charts

struct ExamGradingSchemeView: View {
    @ObservedObject var examVM: ExamViewModel
    
    var body: some View {
        VStack {
            Button("Reset to default") {
                examVM.resetToDefaultGradeSchema()
            }
            Text("Anzahl an Durchgefallenen: \(examVM.getNumberOfGrades(for: 5) + examVM.getNumberOfGrades(for: 6))")
            Chart {
                ForEach(examVM.getChartData()) { grade in
                    BarMark(
                        x: .value("Grade", grade.label),
                        y: .value("Anzahl", Int(grade.value))
                    )
                }
            }
            GraphViewControllerReprestable(examVM: examVM)
        }.navigationTitle("Noten Schema")
    }
}

