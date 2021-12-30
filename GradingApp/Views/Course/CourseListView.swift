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
    @State var showAlert = !MoreActionsViewModel().halfCorrect()
    @StateObject var selectedHalfYearVM = SelectedHalfYearViewModel()
    @StateObject var editCourseViewModel = CourseEditViewModel()
    @StateObject var undoRedoVM = UndoRedoViewModel()
    @StateObject var backupNotificationBadgeVM = BackupNotificationBadgeViewModel()
    
    @State var firstCourseActive = false
    @State var firstCourse: Course = Course()
    @State var alertType: AlertType = .halfYearWarning
    @State var badgeNumber = UIApplication.shared.applicationIconBadgeNumber
    
    internal var didAppear: ((Self) -> Void)? // Test Reasons
    
    @State private var showNewAlert = false
    
    var body: some View {
        NavigationView {
            List(courses) { course in
                NavigationLink(destination: CourseTabView(course: course), tag: course.id, selection: $activeLink) {
                    Text(course.title).font(.title2)
                    Text("(" + String(course.studentsCount) + ")").font(.footnote)
                }
            }
            .onAppear {
                badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                selectedHalfYearVM.fetchValue()
            }//Wird aufgerufen, wenn der View neu berechnet wird
            .onChange(of: scenePhase, perform: { newPhase in
                if newPhase == .active {
                    badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                }
            }) //Im Hintergrund laufende App wird erneut aufgerufen.
            .alert(isPresented: $showAlert, content: {
                if alertType == .halfYearWarning {
                    return Alert(title: Text("Achtung!"), message: Text("Sie sind möglicherweise im falschen Halbjahr"), dismissButton: .default(Text("Ok")))
                } else {
                    return undoRedoVM.getAlert(viewContext: viewContext)
                }
                
            })
            .padding(.top)
            .navigationTitle(Text("Kurse \(selectedHalfYearVM.activeHalf == .firstHalf ? "1. " : "2. ") Halbjahr"))
            .listStyle(PlainListStyle())
            .fullScreenCover(isPresented: $showMoreActions, content: {
                MoreActionsView().environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                        selectedHalfYearVM.fetchValue()
                    }
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
            backupNotificationBadgeVM.updateOnlineBadge()
            if let course = courses.first, idiom == .pad{
                self.firstCourse = course
                self.firstCourseActive = true
            }
            self.didAppear?(self)
        }
        .environment(\.currentHalfYear, selectedHalfYearVM.activeHalf)
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
            ZStack {
                Image(systemName: "ellipsis.circle")
                if badgeNumber != 0 {
                    Text("\(badgeNumber)").padding(6).background(Color.red).clipShape(Circle()).foregroundColor(.white).offset(x: 14, y: -10)
                }
            }
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

