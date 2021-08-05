//
//  GradingApp.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

@main
struct GradingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CourseListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
