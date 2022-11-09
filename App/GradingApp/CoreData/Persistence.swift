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
    
    func childViewContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = container.viewContext
        return context
    }
    
    static func copyForEditing<T: NSManagedObject>(of object: T,
                                                   in context: NSManagedObjectContext) -> T {
        guard let object = (try? context.existingObject(with: object.objectID)) as? T else {
            fatalError("Requested copy of managed object that doesn't exist")
        }
        return object
    }
    
    static func persist(_ object: NSManagedObject) {
        object.managedObjectContext?.saveCustom()
        object.managedObjectContext?.parent?.saveCustom()
    }
    
    static func newTemporaryInstance<T: NSManagedObject>(in context: NSManagedObjectContext) -> T {
        return T(context: context)
    }
    
    static func deleteAllCourses(viewContext: NSManagedObjectContext) {
        let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
        for course in fetchedCourses {
            viewContext.delete(course)
            viewContext.saveCustom()
        }
    }
    
    static func resetAllCoreData() {
         // get all entities and loop over them
        let entityNames = shared.container.managedObjectModel.entities.map({ $0.name!})
        print("Delete \(entityNames.count) Objects")
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
