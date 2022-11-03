//
//  ExerciseView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI

struct ExerciseView: View {
    
    @ObservedObject var examVM: ExamViewModel
    @ObservedObject var exercise: ExamViewModel.ExerciseVM
    
    @State var textField: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Exercise Name: ")
                TextField("Aufgabe...", text: $exercise.title)
                    .onChange(of: exercise.title) { _ in
                        examVM.objectWillChange.send()
                    }
                    
            }
            TextField("..", text: $textField)
            Spacer()
        }
    }
}

