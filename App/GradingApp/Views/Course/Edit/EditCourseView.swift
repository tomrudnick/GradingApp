//
//  EditCourseView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 09.08.21.
//

import SwiftUI

struct EditCourseView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var course: CourseEditViewModel.CourseVM
    
    
    var body: some View {
        SingleCourse(viewTitle: "Kurs bearbeiten", courseName: course.name, courseSubject: course.subject, courseAgeGroup: course.ageGroup, courseType: course.type, courseOralWeight: course.oralWeight){  (name, subject, weight, ageGroup, type) in
            course.name = name
            course.subject = subject
            course.ageGroup = ageGroup
            course.oralWeight = weight
            course.ageGroup = ageGroup
            course.type = type
        }
    }
   
}

/*struct EditCourse_Previews: PreviewProvider {
    static var previews: some View {
        EditCourseView()
    }
}
*/

