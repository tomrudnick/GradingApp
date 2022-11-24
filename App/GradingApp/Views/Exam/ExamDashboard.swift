//
//  ExamDashboard.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import SwiftUI
import Combine

struct ExamDashboard: View {
    
    @ObservedObject var exam: Exam
    @State var showGradeToPoints = true
    @State var showGradeToCount = true
    
    var body: some View {
        VStack {
            Form {
                Section("Exam Settings") {
                    HStack {
                        Text("Exam Title:")
                        Spacer()
                        TextField("Title...", text: $exam.name)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Exam Date:")
                        DatePicker("", selection: $exam.date, displayedComponents: DatePickerComponents.date)
                    }
                    HStack {
                        Text("Maximal Erreichbare Punkte")
                        Text(String(format: "%.2f", exam.getMaxPointsPossible())).bold()
                    }
                    
                    HStack {
                        Text("Durschnitt")
                        Text(String(format: "%.2f", exam.getAverage())).bold()
                        Spacer()
                        Text("Durchgefallen: ")
                        Text("\(exam.getNumberOfGrades(for: exam.failedGrades))")
                        if exam.examParticipations.filter(\.participated).count > 0 {
                            Gauge(value: Double(exam.getNumberOfGrades(for: exam.failedGrades)),
                                  in: 0...Double(exam.examParticipations.filter(\.participated).count)
                            ) {
                                Text("")
                            } currentValueLabel: {
                                Text(String(format: "%.2f", exam.getPercentageOfFailed()))
                            }.gaugeStyle(.accessoryCircularCapacity)
                                .tint(.purple)
                        }
                    }
                }
                ExamGradeToPointsView(exam: exam, show: $showGradeToPoints)
                ExamToGradeCountView(exam: exam, show: $showGradeToCount)
                Section("Exam Aufgaben Übersicht") {
                    Table(exam.sortedParticipatingStudents) {
                        TableColumn("Vorname", value: \.firstName)
                        TableColumn("Nachname", value: \.lastName)
                        TableColumn("Punkte") { student in
                            Text(String(format: "%.2f", exam.getTotalPoints(for: student)))
                        }
                        TableColumn("Grade") { student in
                            Text("\(exam.getGrade(for: student))")
                        }
                    }.frame(height: CGFloat(exam.examParticipations.filter(\.participated).count) * 100)
                }
                
                
            }
        }.navigationTitle("Exam Dashboard")
       
    }
}


