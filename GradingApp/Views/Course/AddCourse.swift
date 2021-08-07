//
//  EditCourseView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct AddCourse: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var courseName = ""
    
    var body: some View {
        VStack {
            VStack {
                HStack{
                    Text("Kurs hinzufügen").font(.headline)
                Spacer()
                    ButtonCancelView()
                }
            }
            .padding()
            CustomTextfieldView(label: "Kursname", input: $courseName)
            CustomButtonView(label: "Speichern", action: saveButtonPressed, buttonColor: .accentColor)
            .disabled(courseName.isEmpty)
            Spacer()
        }
    }
        
    func saveButtonPressed() {
        Course.addCourse(courseName: courseName, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
   
}

//----------------------------Preview-------------------------------

struct AddCourseView_Previews: PreviewProvider {
    static var previews: some View {
        AddCourse().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
