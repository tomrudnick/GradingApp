//
//  EditStudentDetailView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 16.08.21.
//

import SwiftUI

struct EditStudentDetailView: View {
    
    let student: Student.DataModel
    
    var body: some View {
        HStack {
            if student.deleted {
                Text("\(student.firstName) \(student.lastName)")
                    .strikethrough()
                    .font(.title2)
                    
                Text("\(student.email)")
                    .strikethrough()
            } else {
                Text("\(student.firstName) \(student.lastName)").font(.title2)
                Text("\(student.email)")
            }
            
        }
        
    }
}

struct EditStudentDetailView_Previews: PreviewProvider {
    static let student = Student.DataModel(firstName: "Tom", lastName: "Rudnick", email: "tom@rudnick.ch")
    static var previews: some View {
        EditStudentDetailView(student: student)
    }
}
