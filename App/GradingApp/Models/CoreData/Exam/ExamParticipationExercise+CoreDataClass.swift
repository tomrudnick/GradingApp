//
//  ExamParticipationExercise+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//
//

import Foundation
import CoreData

@objc(ExamParticipationExercise)
public class ExamParticipationExercise: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey { case id, points }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try! container.decode(UUID.self, forKey: .id)
        points = try! container.decode(Double.self, forKey: .points)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(points, forKey: .points)
    }
}
