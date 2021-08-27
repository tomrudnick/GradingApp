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
    private let keyValStore = NSUbiquitousKeyValueStore()
    
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
        self.half = keyValStore.longLong(forKey: selectedHalfKey) == 0 ? .firstHalf : .secondHalf
        
        let df = DateFormatter()
        df.dateFormat = dateFormat
        if let date = keyValStore.string(forKey: firstHalfKey) {
            self.dateFirstHalf = df.date(from: date)!
        } else {
            self.dateFirstHalf = Date()
        }
        
        if let date = keyValStore.string(forKey: secondHalfKey) {
            self.dateSecondHalf = df.date(from: date)!
        } else {
            self.dateSecondHalf = Date()
        }
        
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
        keyValStore.set(df.string(from:self.dateFirstHalf), forKey: firstHalfKey)
        keyValStore.set(df.string(from:self.dateSecondHalf), forKey: secondHalfKey)
        keyValStore.set(self.half == .firstHalf ? 0 : 1, forKey: selectedHalfKey)
        keyValStore.synchronize()
    }
}
