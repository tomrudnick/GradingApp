//
//  ExamToGradeCountView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.11.22.
//

import SwiftUI

struct ExamToGradeCountView: View {
    @ObservedObject var exam: Exam
    @Binding var show: Bool
    var body: some View {
        Section {
            if show {
                List {
                    HStack {
                        Text("Note").bold().foregroundColor(Color.accentColor)
                        Spacer()
                        Text("Vorkommen").bold().foregroundColor(Color.accentColor)
                    }
                    ForEach(exam.mapGradesToNumberOfOccurences.reversed(), id: \.id) { gradeNumber in
                        HStack {
                            Text(gradeNumber.grade)
                            Spacer()
                            Text(gradeNumber.number).padding(.trailing)
                        }

                    }
                }
            }
        } header: {
            HStack {
                Text("Notenübersicht")
                Spacer()
                Button {
                    withAnimation {
                        self.show.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(show ? 90 : 0))
                }

            }
        }
    }
}

