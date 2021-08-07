//
//  StudentListView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct StudentListView: View {
    
    @ObservedObject var course: Course
    

    var body: some View {
        List {
            ForEach(course.studentsArr) { student in
                NavigationLink(destination: StudentView(student: student)) {
                    HStack {
                        Text(student.firstName).frame(alignment: .leading)
                        Text(student.lastName).frame(alignment: .leading)
                    }
                }
            }
        }
    }
}


//----------------------------Preview-------------------------------
struct StudentListView_Previews: PreviewProvider {
    static var previewCourse : Course {
        let course = Course(context: PersistenceController.preview.container.viewContext)
        course.name = "Mathe 10F"
        let student = Student(context: PersistenceController.preview.container.viewContext)
        student.lastName = "Rudnick"
        student.firstName = "Tom"
        course.students = [student]
        return course
    }

    static var previews: some View {
        NavigationView {
            StudentListView(course: previewCourse)
        }
    }
}
