//
//  EditCourseView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct EditCourseView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var editVM = CourseEditViewModel()
    
    var body: some View {
        VStack {
            HStack {
                cancelButton
                Spacer()
                saveButton
            }.padding()
            Form {
                Section {
                    List {
                        ForEach(editVM.courses) { course in
                            EditDetailView(course: course)
                        }
                        .onDelete(perform: editVM.deleteCoursesEdit)
                    }
                }
            }
        }
    }
    
    var cancelButton: some View{
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Cancel")
        }
    }
    
    var saveButton: some View {
        Button {
            editVM.save()
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Save")
        }

    }
}

struct EditDetailView: View {
    @ObservedObject var course: CourseEditViewModel.CourseVM
    
    var body: some View {
        HStack {
            Image(systemName: course.hidden ? "eye.slash" : "eye").onTapGesture {
                course.hidden.toggle()
            }
            TextField("", text: $course.name)
                .font(.title2)
                .padding(.bottom)
                .padding(.top)
        }
        
    }
}

struct EditCourseView_Previews: PreviewProvider {
    static var previews: some View {
        EditCourseView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
