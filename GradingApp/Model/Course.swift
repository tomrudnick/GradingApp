//
//  course.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 18.07.21.
//

import Foundation


class Course: Identifiable {
    let id: String
    var name: String
    var students: [Student]
    
    init(id : String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
        self.students = []
    }
    
    init(id : String = UUID().uuidString, name: String, students: [Student]) {
        self.id = id
        self.name = name
        self.students = students
    }
    
    func findStudent(firstName: String, lastName: String) -> Student? {
        return students.first(where: {$0.firstName == firstName && $0.lastName == lastName})
    }
}


