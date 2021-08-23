//
//  CourseTabView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct CourseTabView: View {
    
    @ObservedObject var course: Course
    @State var showAddStudent = false
    @State var showAddMultipleGrades = false
    
    
    var body: some View {
        TabView {
            StudentListView(course: course)
                .tabItem {
                    Image(systemName:"person.3.fill")
                    Text("Kurs")
                }
            StudentGradeListView(course: course)
                .tabItem {
                    Image(systemName:"person.3.fill")
                    Text("Noten")
                }
            
            
        }
        //.edgesIgnoringSafeArea(.top)
        .navigationBarTitle(course.name, displayMode: .inline)
        .toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Button(action: {
                    showAddStudent = true
                }, label: {
                    Image(systemName: "plus.circle")
                })
            }
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                Button(action: {
                    showAddMultipleGrades = true
                }, label: {
                    Text("Note")
                })
            }
        })
        .sheet(isPresented: $showAddStudent, content: {
            AddStudent(course: course)
        })
        .fullScreenCover(isPresented: $showAddMultipleGrades, content: {
            AddMultipleGradesView(course: course)
        })
    }
}

struct CourseTabView_Previews: PreviewProvider {
    
    static let course = previewData(context: PersistenceController.preview.container.viewContext).first!
    
    static var previews: some View {
        NavigationView {
            CourseTabView(course: course)
        }
    }
}

