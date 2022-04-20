//
//  StudentTranscriptGradesFullYearView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 01.09.21.
//

import SwiftUI

struct StudentTranscriptGradesFullYearView: View {
    
    @StateObject var viewModel = TranscriptGradesViewModel()
    @ObservedObject var course: Course
    
    var body: some View {
        StudentTranscriptGradesView(course: course, viewModel: viewModel) { student in
            StudentTranscriptDetailView(student: student)
        }.onAppear {
            viewModel.fetchData(course: course)
        }
    }
}

/*struct StudentTranscriptGradesFullYearView_Previews: PreviewProvider {
    static var previews: some View {
        StudentTranscriptGradesFullYearView()
    }
}*/
