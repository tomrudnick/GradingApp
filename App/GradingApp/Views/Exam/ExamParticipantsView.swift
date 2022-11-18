//
//  ExamParticipantsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI

struct ExamParticipantsView: View {
    
    @ObservedObject var exam: Exam
    
    var body: some View {
        List {
            ForEach(exam.participations, id: \.student) { examParticipation in
                if examParticipation.student != nil {
                    ExamParticipantView(exam: exam, examParticipation: examParticipation)
                }
            }
        }.navigationTitle(exam.name)
    }
}

struct ExamParticipantView: View {
    var exam: Exam
    @ObservedObject var examParticipation: ExamParticipation
    
    var body: some View {
        HStack {
            Text("\(examParticipation.student!.firstName) \(examParticipation.student!.lastName)")
            Spacer()
            Button {
                exam.toggleParticipation(for: examParticipation.student!)
            } label: {
                examParticipation.participated ? Image(systemName: "checkmark") : Image(systemName: "xmark")
            }
        }
    }
}
