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
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var course: CourseEditViewModel.CourseVM
    
    @State var studentFirstName = ""
    @State var studentLastName = ""
    @State var email = ""
    @State var fileName = ""
    @State var openFile = false
    @State var showHelpSheed = false
    
    var body: some View {
        VStack {
            HStack{
                Text("Neuer Schüler").font(.headline)
            Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                }
            }
            .padding()
            CustomTextfieldView(label: "Vorname", input: $studentFirstName)
            CustomTextfieldView(label: "Nachname", input: $studentLastName)
            CustomTextfieldView(label: "Email", input: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            CustomButtonView(label: "Hinzufügen", action: self.saveButtonPressed , buttonColor: .accentColor)
                .disabled(studentFirstName.isEmpty || studentLastName.isEmpty)
                Divider()
            HStack {
                CustomButtonView(label: "csv-Import", action: {openFile.toggle()}, buttonColor: .red)
                Button {
                    self.showHelpSheed.toggle()
                } label: {
                    Image(systemName: "questionmark.circle").imageScale(.large)
                }.padding(.trailing)
            }
            Spacer()
        }
        .fileImporter(isPresented: $openFile, allowedContentTypes: [.plainText, .commaSeparatedText]) { res in
            course.addCSVStudent(res: res)
            dismiss()
        }.sheet(isPresented: $showHelpSheed, onDismiss: {}) {
            CSVImportExampleView()
        }
    }
 
    func saveButtonPressed() {
        course.addStudent(firstName: studentFirstName, lastName: studentLastName, email: email)
        dismiss()
    }
}

//----------------------------Preview-------------------------------

/*struct AddStudent_Previews: PreviewProvider {
    static var previewCourse : Course {
        let course = Course(context: PersistenceController.preview.container.viewContext)
        course.subject = "Mathe"
        course.name = "11D"
        return course
    }
    static var previews: some View {
        AddStudent(course: previewCourse).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}*/
