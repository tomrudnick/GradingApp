//
//  NewExamView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.11.22.
//

import SwiftUI

struct NewExamView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var examVM = ExamVM()
    var course: Course

    var body: some View {
        Group {
            if let exam = examVM.exam {
                ExamView(exam: exam, childContext: examVM.context) {
                    examVM.persist()
                    course.students.forEach { $0.objectWillChange.send() }
                    exam.objectWillChange.send()
                } delete: {
                    
                }
            } else {
                Text("Something went wrong")
            }
        }.onAppear {
            self.examVM.setup(course: course, half: appSettings.activeHalf, viewContext: viewContext)
        }
    }
}

