//
//  GradingAppApp.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 16.07.21.
//

import SwiftUI

@main
struct GradingApp: App {
    @StateObject var courseViewModel = CourseListViewModel()
    var body: some Scene {
        WindowGroup {
            CourseListView().environmentObject(courseViewModel)
        }
    }
}
