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
                cancelButton
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.top)
            TextField("Kursname", text: $courseName)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
            Button(action: saveButtonPressed, label: {
                Text("Speichern")
                    .foregroundColor(.white)
                    .font(.headline)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            })
            .disabled(courseName.isEmpty)
            .padding()
            Spacer()
        }
    }
    var cancelButton: some View{
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Abbrechen")
            }
        }
        
    func saveButtonPressed() {
        Course.addCourse(courseName: courseName, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
   
}

struct AddCourseView_Previews: PreviewProvider {
    static var previews: some View {
        AddCourse().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
