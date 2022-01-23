//
//  MoreActionsViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation
import CoreData
import Combine



class MoreActionsViewModel: ObservableObject {
    struct KeyValueConstants {
        static let dateFormat = "dd.MM.yyyy"
        static let firstHalf = "dateFirstHalf"
        static let secondHalf = "dateSecondHalf"
        static let selectedHalf = "selectedHalf"
    }
    
    enum BackupType {
        case backup
        case export
    }
    
    @Published var dateFirstHalf: Date
    @Published var dateSecondHalf: Date
    @Published var half: HalfType
    @Published var backupType: BackupType = .backup
    @Published var canceallable: AnyCancellable?
    
    var selectedHalf : Int {
        get {
            half == .firstHalf ? 0 : 1
        }
        set {
            half = newValue == 0 ? .firstHalf : .secondHalf
        }
    }
    
    init() {
        self.half = NSUbiquitousKeyValueStore.default.longLong(forKey: KeyValueConstants.selectedHalf) == 0 ? .firstHalf : .secondHalf
        
        let df = DateFormatter()
        df.dateFormat = KeyValueConstants.dateFormat
        if let date = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.firstHalf) {
            self.dateFirstHalf = df.date(from: date)!
        } else {
            self.dateFirstHalf = Date()
        }
        
        if let date = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.secondHalf) {
            self.dateSecondHalf = df.date(from: date)!
        } else {
            self.dateSecondHalf = Date()
        }
        canceallable = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { value in
                self.half = NSUbiquitousKeyValueStore.default.longLong(forKey: KeyValueConstants.selectedHalf) == 0 ? .firstHalf : .secondHalf
                
                let df = DateFormatter()
                df.dateFormat = KeyValueConstants.dateFormat
                if let date = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.firstHalf) {
                    self.dateFirstHalf = df.date(from: date)!
                } else {
                    self.dateFirstHalf = Date()
                }
                
                if let date = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.secondHalf) {
                    self.dateSecondHalf = df.date(from: date)!
                } else {
                    self.dateSecondHalf = Date()
                }
            })
    }
    
//    func getBackupFiles(viewContext: NSManagedObjectContext) -> [Any] {
//        switch backupType {
//        case .backup:
//            return getOneJsonFile(viewContext: viewContext)
//        case .export:
//            return getSingleCSVFiles(viewContext: viewContext)
//        }
//    }
    

    func getOneJsonFile(viewContext: NSManagedObjectContext) -> JSONFile {
        var jsonData: Data = Data()
        do {
            let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
            jsonData = try JSONEncoder().encode(fetchedCourses)
                
        } catch {
            print("Error fetching data from CoreData", error)
        }
        return JSONFile.generateJSONBackupFile(jsonData: String(data: jsonData, encoding: .utf8)!)
    }
    
    func getSingleCSVFiles(viewContext: NSManagedObjectContext) -> [CSVFile] {
        let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
        var files: [CSVFile] = []
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_YYYY"
        let fileDate = dateFormatter.string(from: date)
        for course in fetchedCourses {
            let oralRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 0, course))
            let oralGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: oralRequest)
            files.append(CSVFile.generateCSVFileOFCourse(course: course, grades: oralGrades, fileName: "\(course.title)_muendlich_" + fileDate))
            let writtenRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 1, course))
            let writtenGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: writtenRequest)
            files.append(CSVFile.generateCSVFileOFCourse(course: course, grades: writtenGrades, fileName: "\(course.title)_schriftlich_" + fileDate))
        }
        return files
        
    }

    func done() {
        let df = DateFormatter()
        df.dateFormat = KeyValueConstants.dateFormat
        NSUbiquitousKeyValueStore.default.set(df.string(from:self.dateFirstHalf), forKey: KeyValueConstants.firstHalf)
        NSUbiquitousKeyValueStore.default.set(df.string(from:self.dateSecondHalf), forKey: KeyValueConstants.secondHalf)
        NSUbiquitousKeyValueStore.default.set(self.half == .firstHalf ? 0 : 1, forKey: KeyValueConstants.selectedHalf)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func halfCorrect() -> Bool {
        if half == .firstHalf && Date() >= dateFirstHalf {
            return true
        } else if half == .secondHalf && Date() >= dateSecondHalf {
            return true
        } else {
            return false
        }
    }
    
    func deleteAllCourses(viewContext: NSManagedObjectContext) {
        let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
        for course in fetchedCourses {
            viewContext.delete(course)
            viewContext.saveCustom()
        }
        //Just to be sure delete everything else //This should be optimized in the future
        PersistenceController.resetAllCoreData()
    }
}
