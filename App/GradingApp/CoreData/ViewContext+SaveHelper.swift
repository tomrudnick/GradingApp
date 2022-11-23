//
//  ViewContext+SaveHelper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 08.08.21.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func saveCustom(handler: (_ error: Error?) -> () = saveError) {
        do {
            try save()
            handler(nil)
        } catch {
            handler(error)
        }
    }
    
    static func saveError(error: Error?) {
        if let error = error {
            let error = error as NSError
            fatalError("Error saving database: \(error)")
        }
    }
    
    func childViewContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self
        return context
    }
}
