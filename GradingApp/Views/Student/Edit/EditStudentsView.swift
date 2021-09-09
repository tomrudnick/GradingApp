//
//  EditStudentView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 16.08.21.
//

import SwiftUI

struct EditStudentsView: View {
    
    @ObservedObject var course: CourseEditViewModel.CourseVM
    @State private var selectedStudent: Student.DataModel? = nil
    @State private var showAddStudent = false
    
    
    var body: some View {
        VStack {
            if #available(iOS 15.0, OSX 12.0, macCatalyst 15.0, *) {
                List {
                    ForEach(course.students) { student in
                        EditStudentDetailView(student: student)
                            .contextMenu(ContextMenu(menuItems: {
                                Button(action: {
                                    self.selectedStudent = student
                                }, label: {
                                    Label("Edit", systemImage: "pencil")
                                })
                                Button(role: .destructive, action: {
                                    course.deleteStudentCoursesEdit(id: student.id)
                                }, label: {
                                        if student.deleted {
                                            Label("Restore", systemImage: "arrow.uturn.backward")
                                        } else {
                                            Label("Delete", systemImage: "trash")
                                    }
                                })
                            }))
                            .swipeActions(content: {
                                Button {
                                    self.selectedStudent = student
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }.tint(Color.accentColor)

                                Button {
                                    course.deleteStudentCoursesEdit(id: student.id)
                                } label: {
                                    if student.deleted {
                                        Label("Restore", systemImage: "arrow.uturn.backward")
                                    } else {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }.tint(student.deleted ? Color.purple : Color.red)

                            })
                    }
                }
            } else {
                List {
                    ForEach(course.students) { student in
                        EditStudentDetailView(student: student)
                            .contextMenu(ContextMenu(menuItems: {
                                Button(action: {
                                    self.selectedStudent = student
                                }, label: {
                                    Label("Edit", systemImage: "pencil")
                                })
                                Button(action: {
                                    course.deleteStudentCoursesEdit(id: student.id)
                                }, label: {
                                        if student.deleted {
                                            Label("Restore", systemImage: "arrow.uturn.backward")
                                        } else {
                                            Label("Delete", systemImage: "trash")
                                    }
                                })
                            }))
                    }
                    .onDelete(perform: { indexSet in
                        course.deleteStudentCoursesEdit(atOffsets: indexSet)
                    })
                    
                }
            }
            
        }
        .sheet(item: $selectedStudent, content: { student in
            SingleStudent(viewTitle: "Schüler bearbeiten", student: student) { newStudent in
                course.updateStudent(for: newStudent)
            }
        })
        .sheet(isPresented: $showAddStudent, content: {
            AddStudent(course: course)
        })
        .navigationTitle(course.title)
        .toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Button(action: {
                    showAddStudent = true
                }, label: {
                    Image(systemName: "plus.circle")
                })
            }
        })

    }
    
    private func binding(for student: Student.DataModel) -> Binding<Student.DataModel> {
        guard let studentIndex = course.students.firstIndex(where: {$0.id == student.id}) else {
            fatalError("well... fuck")
        }
        return $course.students[studentIndex]
    }
}
/*struct EditStudentView_Previews: PreviewProvider {
 static var previews: some View {
 EditStudentView()
 }
 }*/

//Don't know how to extract this overload thing into another file at the moment....
