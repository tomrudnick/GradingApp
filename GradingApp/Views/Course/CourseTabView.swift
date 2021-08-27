//
//  CourseTabView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct CourseTabView: View {
    
    @Environment(\.halfYear) var halfYear
    
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
                    Image(systemName:"graduationcap")
                    Text("Leistungsübersicht")
                }
            
            GradeAtDatesSelectionView(course: course)
                .tabItem{
                    Image(systemName:"calendar")
                    Text("Daten")
                }
            
        }
        //.edgesIgnoringSafeArea(.top)
        .navigationBarTitle("\(course.title) - \(halfYear == .firstHalf ? "1. Halbjahr" : "2. Halbjahr")", displayMode: .inline)
        .toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                Text("")
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
           // AddStudent(course: course)
        })
        .if(UIScreen.main.traitCollection.userInterfaceIdiom == .phone, transform: { view in
            view.fullScreenCover(isPresented: $showAddMultipleGrades, content: {
                AddMultipleGradesView(course: course)
            })
        })
        .if(UIScreen.main.traitCollection.userInterfaceIdiom == .pad) { view in
            view.sheet(isPresented: $showAddMultipleGrades, content: {
                AddMultipleGradesView(course: course)
            })
        }
        
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

