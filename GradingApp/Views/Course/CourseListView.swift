//
//  ContentView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import CoreData


struct CourseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(fetchRequest: Course.fetchAllNonHidden(), animation: .default )
    private var courses: FetchedResults<Course>
    
    @State var showEditCourses = false
    @State var showAddCourse = false
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(
                    destination: CourseTabView(course: course),
                    label: {
                        Text(course.name).font(.title2)
                    })
            }
            .padding(.top)
            .navigationTitle(Text("Kurse"))
            .listStyle(PlainListStyle())
            .sheet(isPresented: $showEditCourses) {
                EditCourseView(context: viewContext).environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showAddCourse) {
                AddCourse().environment(\.managedObjectContext, viewContext)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    addButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    editButton
                }
            }
        }
    }
    
    var addButton : some View {
        Button {
            showAddCourse = true
        } label: {
            Image(systemName: "plus.app")
                .font(.title)
        }
    }
    
    var editButton : some View {
        Button {
            showEditCourses = true
        } label: {
            Image(systemName: "pencil.circle")
                .font(.title)
        }
    }
}
    
    //----------------------------Preview-------------------------------
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            CourseListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }

