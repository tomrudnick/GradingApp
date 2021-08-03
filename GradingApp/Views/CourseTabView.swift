//
//  CourseTabView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 19.07.21.
//

import SwiftUI

struct CourseTabView: View {
    
    @StateObject var courseTabViewModel: CourseTabViewModel
    
    init(course: Course) {
        _courseTabViewModel = StateObject(wrappedValue: CourseTabViewModel(course: course))
    }
    
    var body: some View {
        TabView{
            StudentListView(courseTabViewModel: courseTabViewModel)
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
        CourseTabView(course: CourseViewModel().courses[0])
    }
}
