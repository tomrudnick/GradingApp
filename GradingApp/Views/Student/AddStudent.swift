//
//  AddStudent.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import CSV

struct AddStudent: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var course: Course
    
    @State var studentFirstName = ""
    @State var studentLastName = ""
    @State var email = ""
    @State var fileName = ""
    @State var openFile = false
    
    var body: some View {
        VStack {
            Text("Add a new Student").font(.headline).padding()
            TextField("Student first name", text: $studentFirstName)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            TextField("Student last name", text: $studentLastName)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            TextField("Email", text: $email)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button(action: saveButtonPressed, label: {
                Text("Add")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            })
            .padding(.horizontal)
            Divider()
            Button(action: { openFile.toggle() }, label: {
                Text("csv-Import")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
            })
            .padding()
            Spacer()
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.plainText]) { res in
            do {
                let fileUrl = try res.get()
                let csvStudentsData = try! Data(contentsOf: fileUrl)
                let csvStudents = String(data: csvStudentsData, encoding: .utf8)
                let studentArray = try! CSVReader(string: csvStudents!, hasHeaderRow: true)
                while let studentRow = studentArray.next() {
                    Student.addStudent(firstName: studentRow[0], lastName: studentRow[1], email: studentRow[2], course: course, context: viewContext)
                }
                self.presentationMode.wrappedValue.dismiss()
            
            }
            catch {
                print("Error")
            }
        }
    }

    func saveButtonPressed() {
        Student.addStudent(firstName: studentFirstName, lastName: studentLastName, email: email, course: course, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
}


struct AddStudent_Previews: PreviewProvider {
    static var previewCourse : Course {
        let course = Course(context: PersistenceController.preview.container.viewContext)
        course.name = "Mathe 10F"
        return course
    }
    static var previews: some View {
        AddStudent(course: previewCourse).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
