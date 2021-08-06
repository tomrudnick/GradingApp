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

/*struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        StudentListView()
    }
}*/
