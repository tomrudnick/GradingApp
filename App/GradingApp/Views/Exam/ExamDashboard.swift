//
//  ExamDashboard.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI

struct ExamDashboard: View {
    
    @ObservedObject var examVM: ExamViewModel
    
    var body: some View {
        Form {
            Section("Exam Settings") {
                HStack {
                    Text("Exam Title:")
                    Spacer()
                    TextField("Title...", text: $examVM.title)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Exam Date:")
                    DatePicker("", selection: $examVM.date)
                }
            }
        }.navigationTitle("Exam Dashboard")
    }
}

