//
//  CourseListViewTest.swift
//  CourseListViewTest
//
//  Created by Tom Rudnick on 10.09.21.
//

import XCTest
import Combine
import ViewInspector
import SwiftUI
import CoreData

extension CourseListView: Inspectable {}

extension EditCoursesView: Inspectable {}

extension EditCourseDetailView: Inspectable {}

@testable import GradingApp
final class CourseListViewTest: XCTestCase {
    func testFindAllCourses() throws {
        let preview = PersistenceController.preview.container.viewContext
        
        let courses = PersistenceController.fetchData(context: preview, fetchRequest: Course.fetchAll())
        var courseListView = CourseListView()
        
        let exp = courseListView.on(\.didAppear) { view in
            for course in courses {
                let _ = try view.find(text: course.title)
            }
        }
        ViewHosting.host(view: courseListView.environment(\.managedObjectContext, preview))
        wait(for: [exp], timeout: 0.5)
        
    }
    
    func testFindNotHiddenCourse() throws {
        let preview = PersistenceController.preview.container.viewContext
        
        let courses = PersistenceController.fetchData(context: preview, fetchRequest: Course.fetchAll())
        let course = courses.first!
        course.hidden = true
        preview.saveCustom()
        var courseListView = CourseListView()
        
        let exp = courseListView.on(\.didAppear) { view in
            do {
                let _ = try view.find(text: course.title)
                XCTFail()
            } catch {
                print("Success")
            }
        }
        ViewHosting.host(view: courseListView.environment(\.managedObjectContext, preview))
        wait(for: [exp], timeout: 0.5)
    }
    
}

