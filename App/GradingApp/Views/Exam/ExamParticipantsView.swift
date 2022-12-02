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
        VStack {
            HStack {
                Text("Anzahl an Teilnehmer: \(exam.participationCount())")
                Spacer()
                toggleAllParticipants
            }.padding([.leading, .trailing])
            List {
                ForEach(exam.participations, id: \.student) { examParticipation in
                    if examParticipation.student != nil {
                        ExamParticipantView(exam: exam, examParticipation: examParticipation)
                    }
                }
            }
        }.navigationTitle(exam.name)
    }
    
    var toggleAllParticipants: some View {
        Button {
            let participated = self.exam.participationCount() == 0
            self.exam.examParticipations.forEach { $0.participated = participated }
            self.exam.objectWillChange.send() ///This is needed, since the participation Count can't be observed....
        } label: {
            if self.exam.participationCount() > 0 {
                Text("Alle abwählen")
            } else {
                Text("Alle auswählen")
            }
        }
        .buttonStyle(BorderedButtonStyle())

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
                exam.objectWillChange.send()
            } label: {
                examParticipation.participated ? Image(systemName: "checkmark") : Image(systemName: "xmark")
            }
        }
    }
}
