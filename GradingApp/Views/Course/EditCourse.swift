//
//  EditCourse.swift
//  GradingApp
//
//  Created by Tom Rudnick on 09.08.21.
//

import SwiftUI

struct EditCourse: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var course: CourseEditViewModel.CourseVM
    
    var body: some View {
        SingleCourse(viewTitle: "Kurs bearbeiten", courseName: $course.name) {
            print("test")
        }
    }
}

/*struct EditCourse_Previews: PreviewProvider {
    static var previews: some View {
        EditCourse()
    }
}
*/
