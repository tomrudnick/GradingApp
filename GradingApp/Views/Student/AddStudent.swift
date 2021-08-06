//
//  AddStudent.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct AddStudent: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var course: Course
    
    @State var studentFirstName = ""
    @State var studentLastName = ""
    @State var email = ""
    
    var body: some View {
        VStack {
            Text("Add a new Student").font(.headline).padding()
            TextField("Student first name", text: $studentFirstName)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            TextField("Student last name", text: $studentLastName)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            TextField("Email", text: $email)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            Button(action: saveButtonPressed, label: {
                Text("Add")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
                    .background(Color.accentColor)
            })
            .padding()
            Spacer()
        }
    }
    
    func saveButtonPressed() {
        Student.addStudent(firstName: studentFirstName, lastName: studentLastName, email: email, course: course, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
}

/*struct AddStudent_Previews: PreviewProvider {
    static var previews: some View {
        AddStudent()
    }
}*/
