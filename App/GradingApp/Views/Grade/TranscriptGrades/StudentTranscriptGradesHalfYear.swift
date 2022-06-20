//
//  StudentTranscriptGradesFullYearView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 28.08.21.
//

import SwiftUI

struct StudentTranscriptGradesHalfYear: View {
    
    @Environment(\.currentHalfYear) private var halfYear
    @ObservedObject var course: Course
    @StateObject private var viewModel = TranscriptGradesHalfYearViewModel()
    
    var body: some View {
        StudentTranscriptGradesView(course: course, viewModel: viewModel) { student in
            VStack {
                StudentDetailViewTop(student: student)
                StudentDetailView(student: student)
            }
        }.onAppear {
            viewModel.setHalf(halfYear: halfYear)
            viewModel.fetchData(course: course)
        }
    }
}

