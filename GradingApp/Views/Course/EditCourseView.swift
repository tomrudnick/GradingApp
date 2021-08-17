//
//  EditCourseView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 09.08.21.
//

import SwiftUI

struct EditCourseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var course: CourseEditViewModel.CourseVM
    
    var body: some View {
        SingleCourse(viewTitle: "Kurs bearbeiten", courseName: course.name) { name in
            course.name = name
        }
    }
}

/*struct EditCourse_Previews: PreviewProvider {
    static var previews: some View {
        EditCourseView()
    }
}
*/
