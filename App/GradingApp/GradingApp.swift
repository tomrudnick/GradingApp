//
//  GradingApp.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import Combine
import CloudStorage

@main
struct GradingApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    @StateObject var externalScreenhideViewModel = ExternalScreenHideViewModel()
    @CloudStorage(HalfYearDateKeys.selectedHalf) var activeHalf: HalfType = .firstHalf

    var body: some Scene {
        WindowGroup {
            #if targetEnvironment(macCatalyst)
            CourseListView(externalScreenHideViewModel: externalScreenhideViewModel, activeHalf: $activeHalf)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            #else
            CourseListView(externalScreenHideViewModel: externalScreenhideViewModel, activeHalf: $activeHalf)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .onReceive(
                    externalScreenhideViewModel.screenDidConnectPublisher,
                    perform: externalScreenhideViewModel.screenDidConnectNotification
                )
                .onReceive(
                    externalScreenhideViewModel.screenDidDisconnectPublisher,
                    perform: externalScreenhideViewModel.screenDidDisconnect
                )
            #endif
        }
        
        WindowGroup("Note hinzufügen", for: Course.ID.self) { $courseID in
            if let courseID = courseID,
               let course = try? PersistenceController.shared.container.viewContext.fetch(Course.fetchRequest(forID: courseID)).first {
                AddMultipleGradesView(course: course)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            }
        }
    }
}


struct ExternalView: View {
    var body: some View {
        VStack {
            Text("Sensibler Inhalt wird versteckt").font(.system(size: 100.0)).padding(.top)
            Image("AppIcon1024")
                .resizable()
                .scaledToFit()
                .cornerRadius(20.0)
                .padding()
        }
    }
}
