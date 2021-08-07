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
            HStack{
                Text("Neuer Schüler").font(.headline)
            Spacer()
                ButtonCancelView()
            }
            .padding()
            CustomTextfieldView(label: "Vorname", input: $studentFirstName)
            CustomTextfieldView(label: "Nachname", input: $studentLastName)
            CustomTextfieldView(label: "Email", input: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            CustomButtonView(label: "Hinzufügen", action: self.saveButtonPressed, buttonColor: .accentColor)
                .disabled(studentFirstName.isEmpty || studentLastName.isEmpty)
                Divider()
            CustomButtonView(label: "csv-Import", action: {openFile.toggle()}, buttonColor: .red)
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

//----------------------------Preview-------------------------------

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
