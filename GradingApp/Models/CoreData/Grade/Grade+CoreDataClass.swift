//
//  Grade+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//
//

import Foundation
import CoreData

@objc(Grade)
public class Grade: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey { case date, type, value, comment }
    
    required public convenience init(from decoder: Decoder) throws {
            self.init(context: PersistenceController.shared.container.viewContext)
            let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try! container.decode(Date.self, forKey: .date)
        type = try! container.decode(GradeType.self, forKey: .type)
        value = try! container.decode(Int32.self, forKey: .value)
        comment = try! container.decode(String.self, forKey: .comment)
        }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(value, forKey: .value)
        try container.encode(comment, forKey: .comment)
    }

}
