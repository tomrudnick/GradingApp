//
//  CourseListView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 18.07.21.
//

import SwiftUI

struct CourseListView: View {
    var body: some View {
        NavigationView{
            List(courses){ currentCourse in
                NavigationLink( destination: CourseTabView(course: currentCourse.students )
                                    .navigationTitle(currentCourse.name)
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
                    Text(currentCourse.name)
                        .font(.title2)
                }
                .padding(.top)
                .padding(.bottom)
                
            }
            .padding(.top)
            .navigationTitle(Text("Kurse"))
            
        }
    }
}
struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView()
    }
}



