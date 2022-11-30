//
//  ExamGradeToPointsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.11.22.
//

import SwiftUI

struct ExamGradeToPointsView: View {
    @ObservedObject var exam: Exam
    @Binding var show: Bool
    var body: some View {
        Section {
            if show {
                List {
                    ForEach(exam.getPointsToGrade(), id: \.grade) { elem in
                        HStack {
                            Text("\(elem.grade)")
                            Spacer()
                            Text("\(elem.range.description)")
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Notenschlüssel")
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
