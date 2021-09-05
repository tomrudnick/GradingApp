//
//  SingleStudent.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 18.08.21.
//

import SwiftUI

struct SingleStudent: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let viewTitle: String
    @State var student: Student.DataModel
  
    
   
    let saveHandler: (_ student: Student.DataModel) -> ()
    
    init(viewTitle: String, student: Student.DataModel, saveHandler : @escaping (_ student: Student.DataModel) -> ()) {
        self.viewTitle = viewTitle
        self._student = State(initialValue: student)
        self.saveHandler = saveHandler
    }
    var body: some View {
        VStack {
            VStack {
                HStack{
                    Text(viewTitle).font(.headline)
                Spacer()
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Abbrechen")
                    }
                }
            }
            .padding()
            CustomTextfieldView(label: "Vorname", input: $student.firstName)
            CustomTextfieldView(label: "Nachname", input: $student.lastName)
            CustomTextfieldView(label: "Email", input: $student.email)
            CustomButtonView(label: "Speichern", action:{saveButtonPressed()}, buttonColor: .accentColor)
                .disabled(student.firstName.isEmpty || student.lastName.isEmpty)
            Spacer()
        }
    }
        
    func saveButtonPressed() {
        saveHandler(student)
        presentationMode.wrappedValue.dismiss()
    }
}

//struct SingleStudent_Previews: PreviewProvider {
//    @State static var kursName = ""
//    static var previews: some View {
//        SingleStudent(viewTitle: "Schüler bearbeiten") { _ in }
//    }
//}

