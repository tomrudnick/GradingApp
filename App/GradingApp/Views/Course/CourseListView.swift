//
//  ContentView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import CoreData
//import ViewInspector
import UIKit
import Combine
import CloudStorage


struct CourseListView: View {
    
    enum AlertType {
        case undoRedo
        case halfYearWarning
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(fetchRequest: Course.fetchAllNonHidden(), animation: .default )
    private var courses: FetchedResults<Course>
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var showEditCourses = false
    @State var showMoreActions = false
    @State var activeLink: ObjectIdentifier? = nil
    @State var showAlert = false
    @Binding var activeHalf: HalfType
    @StateObject var editCourseViewModel = CourseEditViewModel()
    @StateObject var undoRedoVM = UndoRedoViewModel()
    
    
    @ObservedObject var externalScreenHideViewModel: ExternalScreenHideViewModel
    
    @State var firstCourseActive = false
    @State var firstCourse: Course?
    @State var alertType: AlertType = .halfYearWarning
    
    internal var didAppear: ((Self) -> Void)? // Test Reasons
    
    @State private var showNewAlert = false
    @State private var firstAppear = true
    
    @CloudStorage(HalfYearDateKeys.firstHalf) var dateFirstHalf: Date = Date()
    @CloudStorage(HalfYearDateKeys.secondHalf) var dateSecondHalf: Date = Date()

    init(externalScreenHideViewModel: ExternalScreenHideViewModel, activeHalf: Binding<HalfType>) {
        self._activeHalf = activeHalf
        self.externalScreenHideViewModel = externalScreenHideViewModel
        self._courses = FetchRequest(fetchRequest: Course.fetchHalfNonHidden(half: activeHalf.wrappedValue), animation: .default)
    }
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(destination: CourseTabView(course: course), tag: course.id, selection: $activeLink) {
                    Text(course.title).font(.title2)
                    Text("(" + String(course.studentsCount) + ")").font(.footnote)
                }
            }
            .alert(isPresented: $showAlert, content: {
                if alertType == .halfYearWarning {
                    return Alert(title: Text("Achtung!"), message: Text("Sie sind möglicherweise im falschen Halbjahr"), dismissButton: .default(Text("Ok")))
                } else {
                    return undoRedoVM.getAlert(viewContext: viewContext)
                }
                
            })
            .padding(.top)
            .navigationTitle(Text("Kurse \(activeHalf == .firstHalf ? "1. " : "2. ") Halbjahr"))
            .listStyle(PlainListStyle())
            .fullScreenCover(isPresented: $showMoreActions, content: {
                SettingsView(externalScreenHideViewModel: externalScreenHideViewModel, selectedHalf: $activeHalf).environment(\.managedObjectContext, viewContext)
            })
            .fullScreenCover(isPresented: $showEditCourses) {
                NavigationView {
                    EditCoursesView(editVM: editCourseViewModel).environment(\.managedObjectContext, viewContext)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    editButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    moreActionsButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    undoButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    redoButton
                }
                
            }
            if let course = firstCourse {
                NavigationLink("", destination: CourseTabView(course: course).navigationBarBackButtonHidden(true), isActive: $firstCourseActive)
            }
        }
        .onAppear {
            if firstAppear {
                #if targetEnvironment(macCatalyst)
                print("Removing all Pending Mac Notifications")
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                #endif
                firstAppear = false
                halfCorrect()
            }
            if let course = courses.first, idiom == .pad{
                self.firstCourse = course
                self.firstCourseActive = true
            }
            print("Students count: \(PersistenceController.fetchData(context: viewContext, fetchRequest: Student.fetchAll()).count)")
            print("Grades count:   \(PersistenceController.fetchData(context: viewContext, fetchRequest: Grade.fetchAll()).count)")
            /*print("NULL Students count: \(PersistenceController.fetchData(context: viewContext, fetchRequest: Student.fetchAllNullCourse()).count)")*/
            
            self.didAppear?(self)
            
        }
        .environment(\.currentHalfYear, activeHalf)
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
            Image(systemName: "gearshape.2")
        }
    }
    
    var undoButton: some View {
        Button {
            self.alertType = .undoRedo
            self.undoRedoVM.undoManagerAction = .undo
            self.showAlert = true
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
    }
    
    var redoButton: some View {
        Button {
            self.alertType = .undoRedo
            self.undoRedoVM.undoManagerAction = .redo
            self.showAlert = true
        } label: {
            Image(systemName: "arrow.uturn.forward")
        }
    }
    
    func halfCorrect() {
        if !(activeHalf == .firstHalf && Date() >= dateFirstHalf || activeHalf == .secondHalf && Date() >= dateSecondHalf) {
            alertType = .halfYearWarning
            showAlert = true
        }
    }
}
    
    //----------------------------Preview-------------------------------
    
    /*struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            CourseListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }*/


struct WelcomeViewIpad: View {
    var body: some View {
        Text("Willkommen zurück Matthias!")
            .font(.largeTitle)
            .navigationBarHidden(true)
    }
}

