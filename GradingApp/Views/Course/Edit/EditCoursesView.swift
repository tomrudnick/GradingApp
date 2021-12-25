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
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var editVM: CourseEditViewModel
    @State private var selectedCourse: CourseEditViewModel.CourseVM? = nil
    @State private var showSaveAlert = false
    @State private var saveAlertText = ""
    
    internal var didAppear: ((Self) -> Void)? // Test Reasons
   
    var body: some View {
        VStack {
            #if targetEnvironment(macCatalyst)
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
                                        Label("Bearbeiten", systemImage: "pencil")
                                    })
                                    Button(action: {
                                        editVM.deleteCoursesEdit(for: course)
                                    }, label: {
                                        if course.deleted {
                                            Label("Wiederherstellen", systemImage: "arrow.uturn.backward")
                                        } else {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                    })
                                })
                        })
                }
                .onDelete(
                    perform: editVM.deleteCoursesEdit
                )
                
            }
            #else
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
                                        Label("Bearbeiten", systemImage: "pencil")
                                    })
                                    Button(role: .destructive, action: {
                                        editVM.deleteCoursesEdit(for: course)
                                    }, label: {
                                        if course.deleted {
                                            Label("Wiederherstellen", systemImage: "arrow.uturn.backward")
                                        } else {
                                            Label("Löschen", systemImage: "trash")
                                        }
                                    })
                                }).id(course.deleted ? 0 : 1) //SwiftUIProblem: Hackfix, forced to redraw context menu
                        })
                        .swipeActions {
                            Button {
                                editCourse(course: course)
                            } label: {
                                Label("Bearbeiten", systemImage: "pencil")
                            }.tint(Color.accentColor)

                            Button {
                                editVM.deleteCoursesEdit(for: course)
                            } label: {
                                if course.deleted {
                                    Label("Wiederherstellen", systemImage: "arrow.uturn.backward")
                                } else {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }.tint(course.deleted ? Color.purple : Color.red)
                        }
                }
            }
            #endif
        }
        .onAppear(perform: {
            self.didAppear?(self)
        })
        .alert(isPresented: $showSaveAlert) {
            Alert(title: Text("Achtung!"), message: Text("Möchten sie wirklich speichern?"), primaryButton: .default(Text("Speichern"), action: {
                editVM.save(context: viewContext)
                presentationMode.wrappedValue.dismiss()
            }), secondaryButton: .cancel())
        }
        .sheet(item: $selectedCourse, content: { course in
            EditCourseView(course: course)
        })
        .navigationBarTitle(Text("Kurse bearbeiten"), displayMode: .inline)
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
/*struct EditCourseView_Previews: PreviewProvider {
    
    static var previews: some View {
        EditCoursesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}*/
