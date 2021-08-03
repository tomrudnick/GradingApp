//
//  CourseTabView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 19.07.21.
//

import SwiftUI

struct CourseTabView: View {
    
    @ObservedObject var courseViewModel: CourseViewModel
    
    var body: some View {
        TabView{
            StudentListView(courseViewModel: courseViewModel)
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

/*struct CourseTabView_Previews: PreviewProvider {
    static var previews: some View {
        CourseTabView(course: CourseListViewModel().courses[0])
    }
}
*/
