//
//  StudentListView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 16.07.21.
//

import SwiftUI


struct StudentListView: View {
    
    @ObservedObject var courseViewModel: CourseViewModel
    
    
    var body: some View {
        List{
            ForEach(courseViewModel.course.students) { currentStudent in
                StudentRowView(student: currentStudent)
            }
        }
    }
}


/*struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        StudentListView(courseTabViewModel: CourseViewModel(course: CourseListViewModel().courses[0]))
    }
}*/

