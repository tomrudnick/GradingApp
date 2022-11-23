//
//  Exam+FetchRequests.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.11.22.
//

import Foundation
import CoreData

extension Exam {
    static func fetch(_ predicate: NSPredicate) -> NSFetchRequest<Exam> {
        let request = NSFetchRequest<Exam>(entityName: "Exam")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = predicate
        return request
    }
}
