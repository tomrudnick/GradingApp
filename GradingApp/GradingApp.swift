//
//  GradingApp.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import Combine

@main
struct GradingApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var externalScreenhideViewModel = ExternalScreenHideViewModel()


    var body: some Scene {
        WindowGroup {
            #if targetEnvironment(macCatalyst)
            CourseListView(externalScreenHideViewModel: externalScreenhideViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            #else
            CourseListView(externalScreenHideViewModel: externalScreenhideViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
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
