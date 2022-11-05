//
//  ExerciseParticipationView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import SwiftUI

struct ExerciseParticipationView: View {
   
    @ObservedObject var epvm: ExamViewModel.ExerciseParticipationVM
    @FocusState private var isTextFieldFocused: Bool
    
    var maxPoints: Double
    
    
    var body: some View {
        HStack {
            Text("\(epvm.student.firstName) \(epvm.student.lastName)").bold()
            Spacer()
            TextField("", text: $epvm.pointsText)
                .bold()
                .keyboardType(.decimalPad)
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { isFocused in
                    if !isFocused { epvm.checkMax(maxPoints: maxPoints) }
                }
                .frame(width: 50.0)
        }
    }
}
