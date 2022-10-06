//
//  SchoolYear+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.10.22.
//
//

import Foundation
import CoreData

@objc(SchoolYear)
public class SchoolYear: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey { case  id, name, courses }
    
    
    
    required public convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try! container.decode(String.self, forKey: .name)
        id = try! container.decode(UUID.self, forKey: .id)
        courses = try! container.decode(Set<Course>.self, forKey: .courses)

    }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(id, forKey: .id)
        try container.encode(courses, forKey: .courses)
    }
}
