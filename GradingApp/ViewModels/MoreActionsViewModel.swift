//
//  MoreActionsViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation
import CoreData


struct KeyValueConstants {
    static let dateFormat = "dd.MM.yyyy"
    static let firstHalf = "dateFirstHalf"
    static let secondHalf = "dateSecondHalf"
    static let selectedHalf = "selectedHalf"
}

class MoreActionsViewModel: ObservableObject {
    
    enum BackupType {
        case backup
        case export
    }
    
    @Published var dateFirstHalf: Date
    @Published var dateSecondHalf: Date
    @Published var half: HalfType
    @Published var backupType: BackupType = .backup
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    func getBackupFiles(viewContext: NSManagedObjectContext) -> [CSVFile] {
        switch backupType {
        case .backup:
            return getDocumentsOneFile(viewContext: viewContext)
        case .export:
            return getDocumentsSingleFiles(viewContext: viewContext)
        }
    }
    
    
    func getDocumentsSingleFiles(viewContext: NSManagedObjectContext) -> [CSVFile] {
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
    func getDocumentsOneFile(viewContext: NSManagedObjectContext) -> [CSVFile] {
        let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
        let backupFile = CSVFile.generateCSVCourseData(courses: fetchedCourses)
        return [backupFile]
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
        
    }
    
    
    @objc func onUbiquitousKeyValueStoreDidChangeExternally(notification:Notification)
    {
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
    }
}
