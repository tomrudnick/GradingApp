//
//  EditStudentView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 16.08.21.
//

import SwiftUI

struct EditStudentsView: View {
    
    @ObservedObject var course: CourseEditViewModel.CourseVM
    @State private var showEditStudentSheet = false
    
    var body: some View {
        VStack {
            List {
                ForEach(course.students) { student in
                    EditStudentDetailView(student: binding(for: student))
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                showEditStudentSheet = true
                            }, label: {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit")
                                }
                                
                            })
                            Button(action: {
                                course.deleteStudentCoursesEdit(id: student.id)
                            }, label: {
                                HStack {
                                    if student.deleted {
                                        Image(systemName: "arrow.uturn.backward")
                                        Text("Restore")
                                    } else {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                                    
                                }
                            })
                        }))
                        .sheet(isPresented: $showEditStudentSheet, content: {
                            EditStudentView(student: binding(for: student))
                        })
                }
                .onDelete(perform: { indexSet in
                    course.deleteStudentCoursesEdit(atOffsets: indexSet)
                })
                
            }
        }.navigationTitle(course.name)
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
