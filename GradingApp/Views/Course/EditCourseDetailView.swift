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
            TextField("", text: $course.name)
                .font(.title2)
                .padding(.bottom)
                .padding(.top)
        }
        
    }
}

//struct EditCourseDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        EditCourseDetailView(course: <#CourseEditViewModel.CourseVM#>).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
