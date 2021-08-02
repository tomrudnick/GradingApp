//
//  CourseTabView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 19.07.21.
//

import SwiftUI

struct CourseTabView: View {
    
    var course: [Student]
    
    var body: some View {
        TabView{
            StudentListView(course: course)
                .tabItem {
                    Image(systemName:"person.3.fill")
                    Text("Kurs")
                }
            NavigationView{
                
            }
            .tabItem {
                Image(systemName:"graduationcap.fill")
                Text("Notenübersicht")
            }
        }
        
    }
}

struct CourseTabView_Previews: PreviewProvider {
    static var previews: some View {
        CourseTabView(course: studentsMathe7F)
    }
}
