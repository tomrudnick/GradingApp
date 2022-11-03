//
//  ExamDashboard.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI
import Combine

struct ExamDashboard: View {
    
    @ObservedObject var examVM: ExamViewModel
    var maxValue: Double = 10.0
    @State var tmp: String = "0"
    @FocusState private var isTextFieldFocused: Bool
    
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
                
                HStack {
                    TextField("Input", text: $tmp)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                        .onReceive(Just(tmp)) { newValue in
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.tmp = filtered
                            }
                        }.onChange(of: isTextFieldFocused) { isFocused in
                            if !isFocused {
                                guard let convertedValue = Double(self.tmp) else { self.tmp = "0"; return }
                                if convertedValue > maxValue {
                                    self.tmp = String(format: "%.2f", maxValue)
                                }
                            }
                        }     
                }
            }
        }.navigationTitle("Exam Dashboard")
    }
}

