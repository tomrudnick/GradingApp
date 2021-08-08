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
        container = NSPersistentContainer(name: "GradingAppData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    static func fetchData<T>(fetchRequest: NSFetchRequest<T>) -> [T] {
        let context = PersistenceController.shared.container.viewContext
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
    
    static let empty: PersistenceController = {
        return PersistenceController(inMemory: true)
    }()
    
// Code for Previews
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let previewCourses = Course.previewCourses(context: viewContext)
        for student in Student.expampleStudents(context: viewContext) {
            Student.addStudent(firstName: student.firstName, lastName: student.lastName, email: student.email, course: previewCourses.first!, context: viewContext)
        }
    
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
 
}
