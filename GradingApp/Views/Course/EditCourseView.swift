//
//  EditCourseView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import CoreData

struct EditCourseView: View {
    
    @Environment(\.presentationMode) var presentationMode
    private var viewContext: NSManagedObjectContext
    
    @StateObject var editVM: CourseEditViewModel
    @State private var showAlert = false
    
    init(context: NSManagedObjectContext) {
        _editVM = StateObject(wrappedValue: CourseEditViewModel(context: context))
        self.viewContext = context
    }
    
    var body: some View {
        VStack {
            HStack {
                CancelButtonView(label: "Abbrechen")
                Spacer()
                saveButton
            }.padding()
            Form {
                Section {
                    List {
                        ForEach(editVM.courses) { course in
                            EditCourseDetailView(course: course)
                        }
                        .onDelete(
                            perform: editVM.deleteCoursesEdit
                        )
                    }
                }
            }
        }
    }
    var saveButton: some View {
        Button {
            editVM.save()
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Speichern")
        }

    }
}
struct EditCourseView_Previews: PreviewProvider {
    static var previews: some View {
        EditCourseView(context: PersistenceController.preview.container.viewContext)
    }
}
