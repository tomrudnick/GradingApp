//
//  SchoolYear+Helper.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 10.09.22.
//

import Foundation
import CoreData

extension SchoolYear{
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    public convenience init(name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
    }
    static func addSchoolYear(name: String, context: NSManagedObjectContext) {
        let _ = SchoolYear(name: name, context: context)
        context.saveCustom()
    }
    static func fetchAll() -> NSFetchRequest<SchoolYear> {
        let request = NSFetchRequest<SchoolYear>(entityName: "SchoolYear")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SchoolYear.name_, ascending: true)]
        return request
    }
}

