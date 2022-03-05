//
//  Subject+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.03.22.
//
//

import Foundation
import CoreData

extension Subject {
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
}

@objc(Subject)
public class Subject: NSManagedObject, Codable {
    private enum CodingKeys: String, CodingKey {case name}
    
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try! container.decode(String.self, forKey: .name)
    }
    
    public convenience init(name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name_ = name
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    
    static func fetchAll() -> NSFetchRequest<Subject> {
        let request = NSFetchRequest<Subject>(entityName: "Subject")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Subject.name_, ascending: true)]
        return request
    }
    
    static func addSubject(name: String, context: NSManagedObjectContext) {
        let _ = Subject(name: name, context: context)
        context.saveCustom()
    }
}
