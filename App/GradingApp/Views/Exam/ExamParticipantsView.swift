//
//  ExamParticipantsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI

struct ExamParticipantsView: View {
    
    @ObservedObject var examVM: ExamViewModel
    
    var body: some View {
        List {
            ForEach(examVM.sortedParticipants, id: \.student) { (student, participation) in
                HStack {
                    Text("\(student.firstName) \(student.lastName)")
                    Spacer()
                    Button {
                        examVM.toggleParticipation(for: student)
                    } label: {
                        participation ? Image(systemName: "checkmark") : Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

