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
    
    @State var showEditCourses = false
    @State var showAddCourse = false
    @State var showMoreActions = false
    @State var activeLink: ObjectIdentifier? = nil
    @State var showAlert = !MoreActionsViewModel().halfCorrect()
    @StateObject var selectedHalfYearVM = SelectedHalfYearViewModel()
    @StateObject var editCourseViewModel = CourseEditViewModel()
    
    @State var firstCourseActive = false
    @State var firstCourse: Course = Course()
    
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
                MoreActionsView().environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        selectedHalfYearVM.fetchValue()
                    }
            })
            .fullScreenCover(isPresented: $showEditCourses) {
                NavigationView {
                    EditCoursesView(editVM: editCourseViewModel).environment(\.managedObjectContext, viewContext)
                }
            }
            .sheet(isPresented: $showAddCourse) {
                AddCourse().environment(\.managedObjectContext, viewContext)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    addButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    editButton
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    moreActionsButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    undoButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    redoButton
                }
                
            }
            NavigationLink("", destination: CourseTabView(course: firstCourse).navigationBarBackButtonHidden(true), isActive: $firstCourseActive)
                
        }
        .onAppear {
            if let course = courses.first, idiom == .pad{
                self.firstCourse = course
                self.firstCourseActive = true
            }
        }
        .environment(\.currentHalfYear, selectedHalfYearVM.activeHalf)
    }
    
    var addButton : some View {
        Button {
            showAddCourse = true
        } label: {
            Image(systemName: "plus.app")
        }
    }
    
    var editButton : some View {
        Button {
            editCourseViewModel.fetchCourses(context: viewContext)
            showEditCourses = true
        } label: {
            Image(systemName: "pencil.circle")
        }
    }
    
    var moreActionsButton: some View {
        Button {
            showMoreActions = true
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    var undoButton: some View {
        Button {
            viewContext.undo()
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
    }
    
    var redoButton: some View {
        Button {
            viewContext.redo()
        } label: {
            Image(systemName: "arrow.uturn.forward")
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
