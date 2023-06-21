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
    var course: Course
    @StateObject var examVM = ExamVM()
    
    
    var body: some View {
        Group {
            if let exam = examVM.exam {
                ExamView(exam: exam, childContext: examVM.context) {
                    examVM.persist()
                    course.students.forEach { $0.objectWillChange.send() }
                    exam.objectWillChange.send()
                } delete: {
                    viewContext.delete(self.exam)
                    viewContext.saveCustom()
                    course.students.forEach { $0.objectWillChange.send() }
                }
            } else {
                Text("No Exam")
            }
        }.onAppear {
            self.examVM.setup(exam: exam, half: appSettings.activeHalf, viewContext: viewContext)
        }
    }
}

