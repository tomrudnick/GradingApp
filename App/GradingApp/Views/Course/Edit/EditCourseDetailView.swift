//
//  EditCourseDetailView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.08.21.
//

import SwiftUI

struct EditCourseDetailView: View {
    @ObservedObject var course: CourseEditViewModel.CourseVM
    
    var body: some View {
        HStack {
            Image(systemName: course.hidden ? "eye.slash" : "eye").onTapGesture {
                course.hidden.toggle()
            }
            if course.deleted {
                Text(course.title).strikethrough()
                    .font(.title2)
                    .padding(.bottom)
                    .padding(.top)
                Text("(" + String(course.students.count) + ")")
                    .font(.footnote)
                    .strikethrough()
            }
            else{
                Text(course.title)
                    .font(.title2)
                    .padding(.bottom)
                    .padding(.top)
                Text("(" + String(course.students.count) + ")")
                    .font(.footnote)
            }
        }
        
    }
}

/*struct EditCourseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EditCourseDetailView(course: CourseEditViewModel.CourseVM(id: UUID(), name: "Mathe 10b", hidden: false, deleted: false, students: [CourseEditViewModel.StudentData(firstName: "Tom", lastName: "Rudnick", email: "tom@rudnick.ch")]))
            EditCourseDetailView(course: CourseEditViewModel.CourseVM(id: UUID(), name: "Mathe 10b", hidden: false, deleted: true, students: [CourseEditViewModel.StudentVM(firstName: "Tom", lastName: "Rudnick", email: "tom@rudnick.ch")]))
        }.previewLayout(.sizeThatFits)
        
    }
}*/
