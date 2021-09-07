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
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    private var dummyCourse = Course()
    
    @State var showEditCourses = false
    @State var showAddCourse = false
    @State var showMoreActions = false
    @State var activeLink: ObjectIdentifier? = nil
    @State var showAlert = !MoreActionsViewModel().halfCorrect()
    @StateObject var selectedHalfYearVM = SelectedHalfYearViewModel()
    
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(destination: CourseTabView(course: course), tag: course.id, selection: $activeLink) {
                    Text(course.title).font(.title2)
                    Text("(" + String(course.students.count) + ")").font(.footnote)
                }
            }
            .onAppear {
                //let hashable: Hashable = courses.first!.id
                selectedHalfYearVM.fetchValue()
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("Achtung!"), message: Text("Sie sind möglicherweise im falschen Halbjahr"), dismissButton: .default(Text("Ok")))
            })
            .padding(.top)
            .navigationTitle(Text("Kurse \(selectedHalfYearVM.activeHalf == .firstHalf ? "1. " : "2. ") Halbjahr"))
            .listStyle(PlainListStyle())
            .fullScreenCover(isPresented: $showMoreActions, content: {
                MoreActionsView(onDelete: {
                    if idiom == .pad {
                        self.activeLink = dummyCourse.id
                    }
                }).environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        selectedHalfYearVM.fetchValue()
                    }
            })
            .fullScreenCover(isPresented: $showEditCourses) {
                NavigationView {
                    EditCoursesView(context: viewContext).environment(\.managedObjectContext, viewContext)
                }
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    moreActionsButton
                }
            }
            NavigationLink(destination: WelcomeViewIpad(), tag: dummyCourse.id, selection: $activeLink) { }
        }
        .environment(\.currentHalfYear, selectedHalfYearVM.activeHalf)
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
    
    var moreActionsButton: some View {
        Button {
            showMoreActions = true
        } label: {
            Image(systemName: "ellipsis.circle")
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


struct WelcomeViewIpad: View {
    var body: some View {
        Text("Willkommen zurück Matthias!")
            .font(.largeTitle)
            .navigationBarHidden(true)
    }
}
