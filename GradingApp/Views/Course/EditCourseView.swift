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
                        destination: Text("Destination"),
                        label: {
                            EditCourseDetailView(course: course)
                        })
                        .contextMenu(menuItems: {
                            Button(action: {
                                showEditCourseSheet = true
                                print("Show Edit Course")
                            }, label: {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit")
                                }
                            })
                        })
                        .sheet(isPresented: $showEditCourseSheet, content: {
                            EditCourse(course: course)
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
        EditCourseView(context: PersistenceController.preview.container.viewContext)
    }
}
