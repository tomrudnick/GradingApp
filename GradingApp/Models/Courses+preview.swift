//
//  Courses+preview.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.08.21.
//

import Foundation
import CoreData

extension Course {
    
    static func previewCourses(context: NSManagedObjectContext) -> [Course] {
        let expampleCourseNames = ["Mathe 6C", "Mathe 8F", "Mathe 11D", "Physik 8F", "Physik 11E", "Physik 12 GK"]
        var courses: [Course] = []
        for course in expampleCourseNames {
            let newCourse = Course(context: context)
            newCourse.name = course
            courses.append(newCourse)
        }
        return courses
    }
}
