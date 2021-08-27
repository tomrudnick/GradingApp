//
//  MoreActionsViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation
import CoreData

class MoreActionsViewModel: ObservableObject {
    
    @Published var dateFirstHalf: Date
    @Published var dateSecondHalf: Date
    @Published var half: HalfType
    
    private let dateFormat = "dd.MM.yyyy"
    
    private let firstHalfKey = "dateFirstHalf"
    private let secondHalfKey = "dateSecondHalf"
    private let selectedHalfKey = "selectedHalf"
    
    var selectedHalf : Int {
        get {
            half == .firstHalf ? 0 : 1
        }
        set {
            half = newValue == 0 ? .firstHalf : .secondHalf
        }
    }
    
    init() {
        self.half = NSUbiquitousKeyValueStore.default.longLong(forKey: selectedHalfKey) == 0 ? .firstHalf : .secondHalf
        
        let df = DateFormatter()
        df.dateFormat = dateFormat
        if let date = NSUbiquitousKeyValueStore.default.string(forKey: firstHalfKey) {
            self.dateFirstHalf = df.date(from: date)!
        } else {
            self.dateFirstHalf = Date()
        }
        
        if let date = NSUbiquitousKeyValueStore.default.string(forKey: secondHalfKey) {
            self.dateSecondHalf = df.date(from: date)!
        } else {
            self.dateSecondHalf = Date()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    
    func getDocuments(viewContext: NSManagedObjectContext) -> [CSVFile] {
        let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
        var files: [CSVFile] = []
        for course in fetchedCourses {
            let oralRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 0, course))
            let oralGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: oralRequest)
            files.append(CSVFile.generateCSVFileOFCourse(course: course, grades: oralGrades, fileName: "\(course.title)_muendlich"))
            let writtenRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 1, course))
            let writtenGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: writtenRequest)
            files.append(CSVFile.generateCSVFileOFCourse(course: course, grades: writtenGrades, fileName: "\(course.title)_schriftlich"))
        }
        return files
    }
    
    func done() {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        NSUbiquitousKeyValueStore.default.set(df.string(from:self.dateFirstHalf), forKey: firstHalfKey)
        NSUbiquitousKeyValueStore.default.set(df.string(from:self.dateSecondHalf), forKey: secondHalfKey)
        NSUbiquitousKeyValueStore.default.set(self.half == .firstHalf ? 0 : 1, forKey: selectedHalfKey)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func halfCorrect() -> Bool {
        print(compareDayMonth(Date(), to: dateFirstHalf))
        if half == .firstHalf && compareDayMonth(Date(), to: dateFirstHalf) < 0 {
            return true
        } else if half == .secondHalf && compareDayMonth(Date(), to: dateFirstHalf) < 0 {
            return true
        } else {
            return false
        }
    }
    
    private func compareDayMonth(_ date1: Date, to date2: Date) -> TimeInterval {
        let calendar = Calendar.current
        var newDate1 = Date(timeIntervalSinceReferenceDate: 0)
        var newDate2 = Date(timeIntervalSinceReferenceDate: 0)
        let date1Components = calendar.dateComponents([.month, .day], from: date1)
        let date2Components = calendar.dateComponents([.month, .day], from: date2)
        newDate1 = calendar.date(byAdding: date1Components, to: date1)!
        newDate2 = calendar.date(byAdding: date2Components, to: date2)!
        print("New Date 1: \(newDate1)")
        return newDate1.timeIntervalSince1970 - newDate2.timeIntervalSince1970
    }
    
    @objc func onUbiquitousKeyValueStoreDidChangeExternally(notification:Notification)
    {
        self.half = NSUbiquitousKeyValueStore.default.longLong(forKey: selectedHalfKey) == 0 ? .firstHalf : .secondHalf
        
        let df = DateFormatter()
        df.dateFormat = dateFormat
        if let date = NSUbiquitousKeyValueStore.default.string(forKey: firstHalfKey) {
            self.dateFirstHalf = df.date(from: date)!
        } else {
            self.dateFirstHalf = Date()
        }
        
        if let date = NSUbiquitousKeyValueStore.default.string(forKey: secondHalfKey) {
            self.dateSecondHalf = df.date(from: date)!
        } else {
            self.dateSecondHalf = Date()
        }
    }
}
