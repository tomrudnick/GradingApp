//
//  StudentListView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 16.07.21.
//

import SwiftUI


struct StudentListView: View {
    
    @ObservedObject var courseTabViewModel: CourseTabViewModel
    
    
    var body: some View {
        List{
            ForEach(courseTabViewModel.course.students) { currentStudent in
                StudentRowView(student: currentStudent)
            }
        }
    }
}


struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        StudentListView(courseTabViewModel: CourseTabViewModel(course: CourseViewModel().courses[0]))
    }
}

