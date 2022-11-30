//
//  ExamParticipation+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 15.11.22.
//
//

import Foundation
import CoreData

@objc(ExamParticipation)
public class ExamParticipation: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey { case participated, id, participatedExercises }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try! container.decode(UUID.self, forKey: .id)
        participated = try! container.decode(Bool.self, forKey: .participated)
        participatedExercises = try! container.decode(Set<ExamParticipationExercise>.self, forKey: .participatedExercises)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(participated, forKey: .participated)
        try container.encode(id, forKey: .id)
        try container.encode(participatedExercises, forKey: .participatedExercises)
    }
}
