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
    @State private var selectedCourse: CourseEditViewModel.CourseVM? = nil
    @State private var showSaveAlert = false
    @State private var saveAlertText = ""
    
    init(context: NSManagedObjectContext) {
        _editVM = StateObject(wrappedValue: CourseEditViewModel(context: context))
        self.viewContext = context
    }
    
    var body: some View {
        VStack {
            if #available(iOS 15.0, macCatalyst 15.0, OSX 12.0, *) { //if the app is ported to iOS 15 this 'if' statement should be removed
                List {
                    ForEach(editVM.courses) { course in
                        NavigationLink(
                            destination: EditStudentsView(course: course),
                            label: {
                                EditCourseDetailView(course: course)
                                    .contextMenu(menuItems: {
                                        Button(action: {
                                            editCourse(course: course)
                                        }, label: {
                                            Label("Edit", systemImage: "pencil")
                                        })
                                        Button(action: {
                                            editVM.deleteCoursesEdit(for: course)
                                        }, label: {
                                            if course.deleted {
                                                Label("Restore", systemImage: "arrow.uturn.backward")
                                            } else {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        })
                                    })
                            })
                            .swipeActions {
                                Button {
                                    editCourse(course: course)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }.tint(Color.accentColor)

                                Button {
                                    editVM.deleteCoursesEdit(for: course)
                                } label: {
                                    if course.deleted {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                    } else {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }.tint(course.deleted ? Color.purple : Color.red)
                            }
                    }
                }
            } else {
                List {
                    ForEach(editVM.courses) { course in
                        NavigationLink(
                            destination: EditStudentsView(course: course),
                            label: {
                                EditCourseDetailView(course: course)
                                    .contextMenu(menuItems: {
                                        Button(action: {
                                            editCourse(course: course)
                                        }, label: {
                                            Label("Edit", systemImage: "pencil")
                                        })
                                        Button(action: {
                                            editVM.deleteCoursesEdit(for: course)
                                        }, label: {
                                            if course.deleted {
                                                Label("Restore", systemImage: "arrow.uturn.backward")
                                            } else {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        })
                                    })
                            })
                    }
                    .onDelete(
                        perform: editVM.deleteCoursesEdit
                    )
                    
                }
            }
        }
        .alert(isPresented: $showSaveAlert) {
            Alert(title: Text("Achtung!"), message: Text("Möchten sie wirklich speichern?"), primaryButton: .default(Text("Speichern"), action: {
                editVM.save()
                presentationMode.wrappedValue.dismiss()
            }), secondaryButton: .cancel())
        }
        .sheet(item: $selectedCourse, content: { course in
            EditCourseView(course: course)
        })
        .navigationBarTitle(Text("Edit Courses"), displayMode: .inline)
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
            showSaveAlert = true
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
    
    func editCourse(course: CourseEditViewModel.CourseVM) {
        self.selectedCourse = course
    }
    
}
struct EditCourseView_Previews: PreviewProvider {
    static var previews: some View {
        EditCoursesView(context: PersistenceController.preview.container.viewContext)
    }
}
