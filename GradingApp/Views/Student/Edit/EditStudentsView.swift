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
    @State private var selectedStudent: Student.DataModel? = nil
    
    
    
    var body: some View {
        VStack {
            List {
                ForEach(course.students) { student in
                    EditStudentDetailView(student: student)
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                self.selectedStudent = student
                                showEditStudentSheet.toggle()
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
        }.navigationTitle(course.title)
        .sheet(item: $selectedStudent, content: { student in
            SingleStudent(viewTitle: "Schüler bearbeiten", student: student) { newStudent in
                course.updateStudent(for: newStudent)
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
