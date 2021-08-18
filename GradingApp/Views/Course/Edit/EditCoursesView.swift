//
//  EditCoursesView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import CoreData

struct EditCoursesView: View {
    
    @Environment(\.presentationMode) var presentationMode
    private var viewContext: NSManagedObjectContext
    
    @StateObject var editVM: CourseEditViewModel
    @State private var showAlert = false
    @State private var showEditCourseSheet = false
    
    init(context: NSManagedObjectContext) {
        _editVM = StateObject(wrappedValue: CourseEditViewModel(context: context))
        self.viewContext = context
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(editVM.courses) { course in
                    NavigationLink(
                        destination: EditStudentsView(course: course),
                        label: {
                            EditCourseDetailView(course: course)
                                .contextMenu(menuItems: {
                                    Button(action: {
                                        showEditCourseSheet = true
                                    }, label: {
                                        HStack {
                                            Image(systemName: "pencil")
                                            Text("Edit")
                                        }
                                    })
                                    Button(action: {
                                        course.deleted = true
                                        editVM.objectWillChange.send()
                                    }, label: {
                                        HStack {
                                            if course.deleted {
                                                Image(systemName: "arrow.uturn.backward")
                                                Text("Restore")
                                            } else {
                                                Image(systemName: "trash")
                                                Text("Delete")
                                            }
                                        }
                                    })
                                })
                        })
                        .sheet(isPresented: $showEditCourseSheet, content: {
                            EditCourseView(course: course)
                        })
                }
                .onDelete(
                    perform: editVM.deleteCoursesEdit
                )
                
            }
        }.navigationBarTitle(Text("Edit Courses"), displayMode: .inline)
        .toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                saveButton
            }
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                cancelButton
            }
        })
    }
    var saveButton: some View {
        Button {
            editVM.save()
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Speichern")
        }
    }
    
    var cancelButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Abbrechen")
        }
    }
    
}
struct EditCourseView_Previews: PreviewProvider {
    static var previews: some View {
        EditCoursesView(context: PersistenceController.preview.container.viewContext)
    }
}
