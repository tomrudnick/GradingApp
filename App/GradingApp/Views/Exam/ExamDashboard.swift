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
                        Text("Gewichtung:")
                        Spacer()
                        Picker(selection: $exam.multiplier, label: Text(""), content: {
                            ForEach(0..<Grade.gradeMultiplier.count, id: \.self) {index in
                                Text(String(Grade.gradeMultiplier[index])).tag(Grade.gradeMultiplier[index])
                            }
                        }).pickerStyle(SegmentedPickerStyle())
                            .padding(.leading)
                            .frame(maxWidth: 300.0)
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
                        Text("Bestanden: ")
                        Text("\(exam.getNumberOfGrades(for: exam.passedGrades))")
                        if exam.examParticipations.filter(\.participated).count > 0 {
                            Gauge(value: Double(exam.getNumberOfGrades(for: exam.passedGrades)),
                                  in: 0...Double(exam.examParticipations.filter(\.participated).count)
                            ) {
                                Text("")
                            } currentValueLabel: {
                                Text(String(format: "%.2f", exam.getPercentageOfPassed()))
                            }.gaugeStyle(.accessoryCircularCapacity)
                                .tint(.purple)
                        }
                    }
                }
                Section {
                    if showGradeToPoints {
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
                                self.showGradeToPoints.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(showGradeToPoints ? 90 : 0))
                        }

                    }
                }
                Section("Notenübersicht") {
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


