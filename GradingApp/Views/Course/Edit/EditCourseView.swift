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
        SingleCourse(viewTitle: "Kurs bearbeiten", courseName: course.name, courseAgeGroup: course.ageGroup, courseOralWeight: course.oralWeight ) {  (name, weight, ageGroup) in
            course.name = name
            course.ageGroup = ageGroup
            course.oralWeight = weight
            course.ageGroup = ageGroup
        }
    }
   
}

/*struct EditCourse_Previews: PreviewProvider {
    static var previews: some View {
        EditCourseView()
    }
}
*/

