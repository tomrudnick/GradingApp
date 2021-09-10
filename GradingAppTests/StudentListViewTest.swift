//
//  EditCourse.swift
//  EditCourse
//
//  Created by Tom Rudnick on 10.09.21.
//

import XCTest
import Combine
import ViewInspector
import SwiftUI

@testable import GradingApp

extension StudentListView: Inspectable {}




final class StudentListViewTest: XCTestCase {

    func testFindAllStudents() throws {
        let preview = PersistenceController.preview.container.viewContext
        
        let courses = PersistenceController.fetchData(context: preview, fetchRequest: Course.fetchAll())
        let course = courses.first(where: {$0.name == "6C"})!
        for student in course.studentsArr {
            print(student.firstName)
        }
        var studentListView = StudentListView(course: course)
        let exp = studentListView.on(\.didAppear) { view in
            for student in course.studentsArr {
                let _ = try view.find(text: student.firstName)
                let _ = try view.find(text: student.lastName)
            }
        }
        ViewHosting.host(view: studentListView.environment(\.managedObjectContext, preview))
        wait(for: [exp], timeout: 0.1)
    }
}



