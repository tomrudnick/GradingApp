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
    
    var body: some View {
        VStack {
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
                        Text("Maximal Erreichbare Punkte")
                        Text(String(format: "%.2f", examVM.getMaxPointsPossible())).bold()
                    }
                    
                    HStack {
                        Text("Durschnitt")
                        Text(String(format: "%.2f", examVM.getAverage())).bold()
                        Spacer()
                        Text("Bestanden: ")
                        if examVM.participants.filter(\.value).count > 0 {
                            Gauge(value: Double(examVM.getNumberOfGrades(for: [1,2,3,4])), in: 1...Double(examVM.participants.filter(\.value).count)) {
                                Text("")
                            } currentValueLabel: {
                                Text(String(format: "%.2f", examVM.getPercentageOfGrades(for: [1,2,3,4])))
                            }.gaugeStyle(.accessoryCircularCapacity)
                                .tint(.purple)
                        }
                    }
                }
                Section("Exam Aufgaben Übersicht") {
                    Table(examVM.sortedParticipatingStudents) {
                        TableColumn("Vorname", value: \.firstName)
                        TableColumn("Nachname", value: \.lastName)
                        TableColumn("Punkte") { student in
                            Text(String(format: "%.2f", examVM.getTotalPoints(for: student)))
                        }
                        TableColumn("Grade") { student in
                            Text("\(examVM.getGrade(for: student))")
                        }
                    }
                    .frame(height: CGFloat(examVM.sortedParticipants.filter(\.participant).count) * 100)
                }
            }
            
            
        }.navigationTitle("Exam Dashboard")
       
    }
}


