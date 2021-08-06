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
    
    static func saveData() {
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch let error {
            print("ERROR while saving Data: \(error)")
        }
    }
    
    //BOILERPLATE CODE ---------START---------------
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let previewCourses = ["Mathe 6C", "Mathe 8F", "Mathe 11D", "Physik 8F", "Physik 11E"]
        var previewCourse : Course?
        for course in previewCourses {
            let newCourse = Course(context: viewContext)
            newCourse.name = course
            previewCourse = newCourse
        }
        let newStudent = Student(context: viewContext)
        newStudent.course = previewCourse!
        newStudent.firstName = "Marit"
        newStudent.lastName = "Abken"
        newStudent.email = "marit.abken@nige.de"
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    //BOILERPLATE CODE ---------END-------------------
}
