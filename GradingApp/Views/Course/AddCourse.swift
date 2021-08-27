//
//  EditCourseView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct AddCourse: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        SingleCourse(viewTitle: "Neuer Kurs") { (name, subject, weight, ageGroup) in
            Course.addCourse(courseName: name, courseSubject: subject, oralWeight: weight, ageGroup: ageGroup, context: viewContext)
        }
    }
}

//----------------------------Preview-------------------------------

struct AddCourseView_Previews: PreviewProvider {
    static var previews: some View {
        AddCourse().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
