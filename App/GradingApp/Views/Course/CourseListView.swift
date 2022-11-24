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

enum Route: Hashable {

    case student(Student)
    case GradeAtDates(Course, [GradeStudent<Grade>])
    case GradeDetail(Student, GradeType)
    case editGrade(Student, Grade)
    
    func getString() -> String {
        switch self {
        case .student(_):
            return "StudentView"
        case .GradeAtDates(_, _):
            return "GradesAtDatesView"
        case .GradeDetail(_, _):
            return "GradeDetailView"
        case .editGrade(_, _):
            return "EditGradeView"
        }
    }

}

struct CourseListView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @FetchRequest(fetchRequest: Course.fetchAllNonHidden(), animation: .default )
    private var courses: FetchedResults<Course>
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @State var showEditCourses = false
    @State var showMoreActions = false
    @State var activeLink: ObjectIdentifier? = nil
    @State var showAlert = false
    @StateObject var editCourseViewModel = CourseEditViewModel()
    @StateObject var undoRedoVM = UndoRedoViewModel()
    
    
    @ObservedObject var externalScreenHideViewModel: ExternalScreenHideViewModel
    
    internal var didAppear: ((Self) -> Void)? // Test Reasons
    
    @State private var showNewAlert = false
    @State private var firstAppear = true
    @State private var selectedCourse: Course?
    
    @CloudStorage(HalfYearDateKeys.firstHalf) var dateFirstHalf: Date = Date()
    @CloudStorage(HalfYearDateKeys.secondHalf) var dateSecondHalf: Date = Date()
    
    @State private var path: [Route] = []
    @State private var selectedTab: String = "StudentListView"

    init(externalScreenHideViewModel: ExternalScreenHideViewModel, fetchRequest: NSFetchRequest<Course>) {
        self.externalScreenHideViewModel = externalScreenHideViewModel
        self._courses = FetchRequest(fetchRequest: fetchRequest, animation: .default)
    }
    
    var body: some View {
        NavigationSplitView {
            List(courses, selection: $selectedCourse) { course in
                NavigationLink(value: course) {
                    Text(course.title).font(.title2)
                    Text("(" + String(course.studentsCount) + ")").font(.footnote)
                }
            }.onChange(of: selectedCourse, perform: { _ in
                selectedTab = "StudentListView"
            })
            .navigationTitle(Text("Kurse \(appSettings.activeHalf == .firstHalf ? "1. " : "2. ") HJ, \(appSettings.activeSchoolYearName ?? "")"))
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
            .alert(isPresented: $showAlert, content: {
                return undoRedoVM.getAlert(viewContext: viewContext)
            })
            .alert(isPresented: $appSettings.correctHalf.not) {
                return Alert(title: Text("Achtung!"), message: Text("Sie sind möglicherweise im falschen Halbjahr"), dismissButton: .default(Text("Ok")))
            }
        } detail: {
           
            NavigationStack(path: $path) {
                if let selectedCourse {
                    CourseTabView(course: selectedCourse, selectedTab: $selectedTab)
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case let .student(Student):
                                StudentView(student: Student).environment(\.currentHalfYear, appSettings.activeHalf)
                            case let .GradeAtDates(course, GradeStudent):
                                GradeAtDatesEditView(course: course, studentGrades: GradeStudent).environment(\.currentHalfYear, appSettings.activeHalf)
                            case let .GradeDetail(student, type):
                                GradeDetailView(student: student, gradeType: type).environment(\.currentHalfYear, appSettings.activeHalf)
                            case let .editGrade(student, grade):
                                EditSingleGradeView(student: student, grade: grade).environment(\.currentHalfYear, appSettings.activeHalf)
                            }
                        }
                } else {
                    WelcomeViewIpad()
                }
            }
            
        }
       
        .fullScreenCover(isPresented: $showMoreActions, content: {
            SettingsView(externalScreenHideViewModel: externalScreenHideViewModel)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(appSettings)
        })
        .fullScreenCover(isPresented: $showEditCourses) {
            NavigationView {
                EditCoursesView(editVM: editCourseViewModel)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(appSettings)
            }
        }
        .onAppear {
            if firstAppear {
                Task {
                    await delayMerge()
                }
                
                #if targetEnvironment(macCatalyst)
                print("Removing all Pending Mac Notifications")
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                #endif
                firstAppear = false
            }
            self.didAppear?(self)
        }
        .environmentObject(appSettings)
    }
    
    var editButton : some View {
        Button {
            editCourseViewModel.fetchCourses(schoolYear: appSettings.activeSchoolYear!, context: viewContext)
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
            self.undoRedoVM.undoManagerAction = .undo
            self.showAlert = true
        } label: {
            Image(systemName: "arrow.uturn.backward")
        }
    }
    
    var redoButton: some View {
        Button {
            self.undoRedoVM.undoManagerAction = .redo
            self.showAlert = true
        } label: {
            Image(systemName: "arrow.uturn.forward")
        }
    }
    
    private func delayMerge() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        DispatchQueue.main.async {
            appSettings.mergeDuplicatedSchoolYears()
            appSettings.activeSchoolYearName = appSettings.activeSchoolYearName ///Trigger the didSet
            guard let activeSchoolYear = appSettings.activeSchoolYear else { return }
            ///To make sure there exist no nil courses
            appSettings.addExistingCoursesToNewlyCreatedSchoolYear(schoolYear: activeSchoolYear)
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
            //.navigationBarHidden(true)
    }
}

