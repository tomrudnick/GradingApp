//
//  Persistence.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    

    init(inMemory: Bool = false) {
        print("INIT COntainer")
        container = NSPersistentCloudKitContainer(name: "GradingAppData")
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = UndoManager()
    }
    
    static func fetchData<T>(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<T>) -> [T] {
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print(error)
            return []
        }
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("ERROR while saving Data: \(error)")
        }
    }
    
    static func resetAllCoreData() {
         // get all entities and loop over them
        let entityNames = shared.container.managedObjectModel.entities.map({ $0.name!})
         entityNames.forEach { entityName in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

            do {
                try shared.container.viewContext.execute(deleteRequest)
                try shared.container.viewContext.save()
            } catch {
                print("Error Deleting something")
            }
        }
    }
    
    static let empty: PersistenceController = {
        return PersistenceController(inMemory: true)
    }()
    
// Code for Previews
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let courses = previewData(context: viewContext)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
 
}
