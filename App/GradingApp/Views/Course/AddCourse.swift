//
//  EditCourseView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct AddCourse: View {
    @EnvironmentObject var appSettings: AppSettings
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var editVM: CourseEditViewModel
    
    var body: some View {
        SingleCourse(viewTitle: "Neuer Kurs") { (name, subject, weight, ageGroup, type) in
            if let activeSchoolYear = appSettings.activeSchoolYear {
                editVM.addCourse(course: CourseEditViewModel.CourseVM(
                    name: name,
                    subject: subject,
                    hidden: false,
                    ageGroup: ageGroup,
                    oralWeight: weight,
                    type: type, deleted: false,
                    fetchedStudents:[:],
                    schoolYear: activeSchoolYear))
            }
        }
    }
}

//----------------------------Preview-------------------------------

//struct AddCourseView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddCourse().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
