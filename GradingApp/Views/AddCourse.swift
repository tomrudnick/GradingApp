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
            Text("Add a new Course").font(.headline).padding()
            TextField("Add a new Course...", text: $courseName)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            Button(action: saveButtonPressed, label: {
                Text("SAVE")
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
        Course.addCourse(courseName: courseName, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
   
}

/*struct EditCourseView_Previews: PreviewProvider {
    static var previews: some View {
        AddCourse()
    }
}*/
