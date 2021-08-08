//
//  grade+preview.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.08.21.
//

import Foundation
import CoreData

extension Grade {
    
    static func previewGrad(context: NSManagedObjectContext)-> Grade{
        let grade = Grade(context: context)
        
        grade.value = 12
        grade.date = Date()
        grade.type = .oral
        grade.comment = ""
        grade.half = .firstHalf
        grade.multiplier = 1.0
        grade.student = Student.exampleStudent(context: context)
        return grade
    }
}
