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
            .navigationBarItems(leading: addButton, trailing: editButton)
        }
    }
    
    var addButton : some View {
        Button {
            showAddCourse = true
        } label: {
            Text("Add")
        }.sheet(isPresented: $showAddCourse) {
            AddCourse().environment(\.managedObjectContext, viewContext)
        }
    }
    
    var editButton : some View {
        Button {
            showEditCourses = true
        } label: {
            Text("Edit")
        }.sheet(isPresented: $showEditCourses) {
            EditCourseView().environment(\.managedObjectContext, viewContext)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
