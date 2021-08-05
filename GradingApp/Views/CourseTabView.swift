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
    var body: some View {
        TabView {
            StudentListView(course: course)
                .tabItem {
                    Image(systemName:"person.3.fill")
                    Text("Kurs")
                }
        }.navigationTitle(Text(course.name))
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: Button(action: {
            showAddStudent = true
        }) {
            Image(systemName: "plus.circle")
        }).sheet(isPresented: $showAddStudent, content: {
            AddStudent(course: course)
        })
    }
    
    
}

/*struct CourseTabView_Previews: PreviewProvider {
    static var previews: some View {
        CourseTabView()
    }
}*/
