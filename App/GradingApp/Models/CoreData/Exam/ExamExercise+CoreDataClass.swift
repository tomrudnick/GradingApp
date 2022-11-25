//
//  ExamExercise+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//
//

import Foundation
import CoreData

@objc(ExamExercise)
public class ExamExercise: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey { case name, maxPoints, index, participatedExercisesIDs }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try! container.decode(String.self, forKey: .name)
        maxPoints = try! container.decode(Double.self, forKey: .maxPoints)
        index = try! container.decode(Int32.self, forKey: .index)
        let ids = try! container.decode(Set<UUID>.self, forKey: .participatedExercisesIDs)
        participationExercises = ids.setmap(transform: { id in
            let exercise = ExamParticipationExercise(context: PersistenceController.shared.container.viewContext)
            exercise.id = id
            return exercise
        })
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(maxPoints, forKey: .maxPoints)
        try container.encode(index, forKey: .index)
        try container.encode(participationExercises.setmap(transform: \.id), forKey: .participatedExercisesIDs)
    }
}
