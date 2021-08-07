//
//  StudentView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct StudentView: View {
    
    @ObservedObject var student: Student
    
    @State var showAddGradeSheet = false
    
    var body: some View {
        VStack {
            Text("Data of Student")
            HStack {
                VStack {
                    Text("Oral Grades:")
                    List {
                        ForEach(student.gradesArr) { grade in
                            if grade.type == .oral {
                                Text(Grade.gradeValueToLowerSchool(value: Int(grade.value)))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                }
                Divider()
                VStack {
                    Text("Written Grades:")
                    List {
                        ForEach(student.gradesArr) { grade in
                            if grade.type == .written {
                                Text(Grade.gradeValueToLowerSchool(value: Int(grade.value)))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                }
            }
        }.navigationTitle(Text("\(student.firstName) \(student.lastName)"))
        .navigationBarItems(trailing: addGradeButton)
    }
    
    var addGradeButton: some View {
        Button(action: {
            showAddGradeSheet = true
        }, label: {
            Text("Add Grade")
        }).sheet(isPresented: $showAddGradeSheet, content: {
            AddSingleGradeView(student: student)
        })
    }
    
}



struct StudentView_Previews: PreviewProvider {
    static var previewStudent : Student {
        let student = Student(context: PersistenceController.preview.container.viewContext)
        student.firstName = "Marit"
        student.lastName = "Abken"
        return student
    }
    static var previews: some View {
        StudentView(student: previewStudent)
    }
}
