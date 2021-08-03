//
//  EditCoursesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.08.21.
//

import SwiftUI

struct EditCoursesView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var courseListViewModel: CourseListViewModel
    
    
    @State var courseTitle: String = ""
 
    
    var body: some View {
        
        NavigationView{
            Form {
                
                
                Section {
                    TextField("Neuer Kurs", text: $courseTitle)
                }
                
            }
            .navigationBarItems(leading: Button(action: {presentationMode.wrappedValue.dismiss()
            }){
                Text("Abbrechen")
                    .font(.title2)

            }, trailing: Button(action: {
                saveCourse()
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
        courseListViewModel.addCourse(courseTitle: courseTitle)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditDetailView: View {
    
    @ObservedObject var courseViewModel: CourseViewModel
    
    var body: some View {
        TextField("tmp", text: $courseViewModel.course.name)
            .font(.title2)
            .padding(.bottom)
            .padding(.top)
    }
}

struct EditCoursesView_Previews: PreviewProvider {
    static var previews: some View {
        EditCoursesView().environmentObject(CourseListViewModel())
    }
}

