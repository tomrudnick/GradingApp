//
//  CourseListView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 18.07.21.
//

import SwiftUI

struct CourseListView: View {
    
    @EnvironmentObject var courseListViewModel: CourseListViewModel
    @State var showEditCourses = false
    
    
    var body: some View {
        NavigationView {
            Text(courseListViewModel.courseViewModels[0].course.name)
        }
        /*NavigationView{
            List(courseListViewModel.courseViewModels){ courseViewModel in
                NavigationLink( destination: CourseTabView(courseViewModel: courseViewModel)
                                    .navigationTitle(courseViewModel.course.name)
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
                    Text(courseViewModel.course.name)
                        .font(.title2)
                }
                .padding(.top)
                .padding(.bottom)
                
            }
            .padding(.top)
            .navigationTitle(Text("Kurse"))
            .listStyle(PlainListStyle())
            .navigationBarItems(trailing:
                                    Button(action:{
                                        showEditCourses = true
                                    }){
                                        Image(systemName: "pencil.circle" )
                                            .font(.title)
                                    }
                .sheet(isPresented: $showEditCourses) {
                    EditCoursesView()
                })
            
        }*/
    }
}
struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView().environmentObject(CourseListViewModel())
    }
}



