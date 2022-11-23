//
//  EditExamView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 19.11.22.
//

import SwiftUI

struct EditExamView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var viewContext
    var exam: Exam
    @StateObject var examVM = ExamVM()
    
    
    var body: some View {
        Group {
            if let exam = examVM.exam {
                ExamView(exam: exam) {
                    examVM.persist()
                } delete: {
                    viewContext.delete(self.exam)
                    viewContext.saveCustom()
                }
            } else {
                Text("No Exam")
            }
        }.onAppear {
            self.examVM.setup(exam: exam, half: appSettings.activeHalf, viewContext: viewContext)
        }
    }
}

