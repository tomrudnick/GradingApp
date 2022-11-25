//
//  Exam+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//
//

import Foundation
import CoreData

@objc(Exam)
public class Exam: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey { case name, multiplier, half, gradeSchema, date, exercises, participations }
    
    
    required public convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try! container.decode(String.self, forKey: .name)
        multiplier = try! container.decode(Double.self, forKey: .multiplier)
        half = try! container.decode(HalfType.self, forKey: .half)
        gradeSchema = try! container.decode(Dictionary<Int, Double>.self, forKey: .gradeSchema)
        date = try! container.decode(Date.self, forKey: .date)
        exercises = try! container.decode(Set<ExamExercise>.self, forKey: .exercises)
        let participationIDs = try! container.decode(Set<UUID>.self, forKey: .participations)
        examParticipations = participationIDs.setmap {
            let examParticipation = ExamParticipation(context: PersistenceController.shared.container.viewContext)
            examParticipation.id = $0
            examParticipation.exam = self
            return examParticipation
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(multiplier, forKey: .multiplier)
        try container.encode(half.rawValue, forKey: .half)
        try container.encode(gradeSchema, forKey: .gradeSchema)
        try container.encode(date, forKey: .date)
        
        try container.encode(exercises, forKey: .exercises)
        try container.encode(examParticipations.setmap(transform: \.id), forKey: .participations)
    }
}

