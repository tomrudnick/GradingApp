//
//  StudentsListViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.08.21.
//

import Foundation

class CourseTabViewModel: ObservableObject{
    @Published var course: Course
    
    init(course: Course) {
        self.course = course
    }
    
    func addStudent() {
        //TODO
    }
}
