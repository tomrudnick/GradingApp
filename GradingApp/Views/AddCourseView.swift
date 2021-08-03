//
//  AddCourseView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.08.21.
//

import SwiftUI

struct AddCourseView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var courseViewModel: CourseViewModel
    
    @State var courseTitle: String = ""
    
    var body: some View {
        VStack {
            TextField("Course Name: ", text: $courseTitle)
            Button(action: saveCourse) {
                Text("Save Course")
            }
        }
        
        
    }
    
    func saveCourse() {
        courseViewModel.addCourse(courseTitle: courseTitle)
        presentationMode.wrappedValue.dismiss()
        
    }
}

struct AddCourseView_Previews: PreviewProvider {
    static var previews: some View {
        AddCourseView()
    }
}
