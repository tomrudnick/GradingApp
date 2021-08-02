//
//  course.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 18.07.21.
//

import Foundation
import UIKit
import SwiftUI

class Course: Identifiable {
    
    var id = UUID().uuidString
    var name: String
    var students: [Student]
    
    init(name: String, students: [Student]) {
        self.name = name
        self.students = students
    }
}


