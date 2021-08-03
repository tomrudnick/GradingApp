//
//  EditCoursesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.08.21.
//

import SwiftUI

struct EditCoursesView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var courseViewModel: CourseViewModel
    
    
    @State var courseTitle: String = ""
    
    var body: some View {
        
        NavigationView{
            Form {
                Section {
                    List(courseViewModel.courses){ course in
                        TextField(course.name, text: $courseTitle)
                            .font(.title2)
                            .padding(.bottom)
                            .padding(.top)
                    }
                }
                
                Section {
                    Text("Hallo 2")
                }
                
            }
            .navigationBarItems(leading: Button(action: {presentationMode.wrappedValue.dismiss()
            }){
                Text("Abbrechen")
                    .font(.title2)

            }, trailing: Button(action: {
                
            })
                {
                Text("Speichern")
                    .font(.title2 )
                    .bold()
                
            })
            .navigationTitle("Kurse ")
        }
    }
    
    func saveCourse() {
        courseViewModel.addCourse(courseTitle: courseTitle)
        presentationMode.wrappedValue.dismiss()
        
    }
}

struct EditCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        EditCoursesView().environmentObject(CourseViewModel())
    }
}

//Button(action: saveCourse) {
//    Text("Save Course")
//}
