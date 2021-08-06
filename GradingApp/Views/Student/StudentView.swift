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
        Text("Data of Student")
            .navigationTitle(Text(student.firstName))
            .navigationBarItems(trailing: addGradeButton)
    }
    
    var addGradeButton: some View {
        Button {
            showAddGradeSheet = true
        } label: {
            Image(systemName: "plus.circle")
        }.sheet(isPresented: $showAddGradeSheet) {
            AddSingleGradeView(student: student)
        }
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
