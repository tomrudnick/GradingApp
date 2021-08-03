//
//  CourseListView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 18.07.21.
//

import SwiftUI

struct CourseListView: View {
    
    @EnvironmentObject var courseViewModel: CourseViewModel
    
    
    var body: some View {
        NavigationView{
            List(courseViewModel.courses){ course in
                NavigationLink( destination: CourseTabView(course: course)
                    .navigationTitle(course.name)
                    .navigationBarItems(trailing:
                                        Button(action:{}){
                                            VStack{
                                            Image(systemName: "plus.circle" )
                                                Text("Note")
                                                
                                            }
                                        }
                                    )
                            )
                {
                    Text(course.name)
                        .font(.title2)
                }
                .padding(.top)
                .padding(.bottom)
                
            }
            .padding(.top)
            .navigationTitle(Text("Kurse"))
            .navigationBarItems(trailing:
                                    NavigationLink("Add", destination: AddCourseView())
                        )
        }
    }
}
struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}



