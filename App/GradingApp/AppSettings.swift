//
//  GlobalSettings.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.10.22.
//

import Foundation
import CloudStorage
import CoreData
import Combine

class AppSettings : ObservableObject {
    @CloudStorage(HalfYearDateKeys.selectedHalf)    var activeHalf            :     HalfType = .firstHalf {
        didSet {
            correctHalf = (activeHalf == .firstHalf && Date() >= dateFirstHalf || activeHalf == .secondHalf && Date() >= dateSecondHalf)
        }
    }
    @CloudStorage(HalfYearDateKeys.firstHalf)       var dateFirstHalf         :     Date = Date()
    @CloudStorage(HalfYearDateKeys.secondHalf)      var dateSecondHalf        :     Date = Date()
    @CloudStorage("Schuljahr")                      var activeSchoolYearName    :     String? {
        didSet {
            if let activeSchoolYearName {
                print("Schuljahr changed DIDSET to \(activeSchoolYearName)")
                let context = PersistenceController.shared.container.viewContext
                context.perform { [self] in
                    self.activeSchoolYear = try? context.fetch(SchoolYear.fetchSchoolYear(name: activeSchoolYearName)).first
                    
                }
            }
        }
    }
    
    @Published var correctHalf: Bool = true
    @Published var activeSchoolYear: SchoolYear?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        if let activeSchoolYearName {
            context.perform { [self] in
                let schoolYears = try? context.fetch(SchoolYear.fetchSchoolYear(name: activeSchoolYearName))
                guard let schoolYears, schoolYears.count > 0 else {
                    createDefaultSchoolYear()
                    return
                }
                if schoolYears.count > 1 {
                    mergeDuplicatedSchoolYears()
                    self.activeSchoolYear = try? context.fetch(SchoolYear.fetchSchoolYear(name: activeSchoolYearName)).first
                } else {
                    self.activeSchoolYear = schoolYears.first
                }
               
            }
        } else { //THIS means that probably no schoolYear exists
            createDefaultSchoolYear()
        }
        
        correctHalf = (activeHalf == .firstHalf && Date() >= dateFirstHalf || activeHalf == .secondHalf && Date() >= dateSecondHalf)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keysDidChangeOnCloud(notification:)),
                                                   name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                                   object: NSUbiquitousKeyValueStore.default)
    }
    
    @objc func keysDidChangeOnCloud(notification: Notification) {
        guard let info = notification.userInfo as? [String: AnyObject], let keys = info[NSUbiquitousKeyValueStoreChangedKeysKey] as? [NSString] else { return }
        guard keys.contains(where: { key in key == "Schuljahr" }) else { return }
        guard let activeSchoolYearName = NSUbiquitousKeyValueStore.default.string(forKey: "Schuljahr") else { return }
        
        let context = PersistenceController.shared.container.viewContext
        context.perform { [self] in
            self.activeSchoolYear = try? context.fetch(SchoolYear.fetchSchoolYear(name: activeSchoolYearName)).first
        }
        print("Schuljahr changed")
    }
    
    func courseFetchRequest() -> NSFetchRequest<Course> {
        if let activeSchoolYearName {
            print("ACTIVE SCHOOLYEAR name: \(activeSchoolYearName)")
            return Course.fetchHalfNonHiddenSchoolYear(half: activeHalf, schoolYearName: activeSchoolYearName)
        } else {
            return Course.fetchHalfNonHidden(half: activeHalf)
        }
        
    }
    
    func addExistingCoursesToNewlyCreatedSchoolYear(schoolYear: SchoolYear) {
        let context = PersistenceController.shared.container.viewContext
        context.perform {
            let courses = try? context.fetch(Course.fetchAllNil())
            guard let courses else { return }
            courses.forEach { $0.schoolyear = schoolYear }
            context.saveCustom()
        }
    }
    
    private func createDefaultSchoolYear() {
        let context = PersistenceController.shared.container.viewContext
        let year = Calendar.current.component(.year, from: Date()) % 100
        let scholYearName = String(format: "%02d", year)+"/"+String(format: "%02d", year+1)
        let activeSchoolYear = SchoolYear(name: scholYearName, context: PersistenceController.shared.container.viewContext)
        activeSchoolYearName = activeSchoolYear.name
        context.saveCustom()
        addExistingCoursesToNewlyCreatedSchoolYear(schoolYear: activeSchoolYear)
    }
    
    func mergeDuplicatedSchoolYears() {
        let schoolYearRequest = SchoolYear.fetchAll()
        let context = PersistenceController.shared.container.viewContext
        context.perform {
            let schoolYears = try? context.fetch(schoolYearRequest)
            guard let schoolYears else { return }
            let dict = Dictionary(grouping: schoolYears, by: { $0.name }).filter { $0.value.count > 1 }
            dict.forEach { (name, years) in
                let first = years.first!
                years.filter { $0.id != first.id }.forEach { $0.courses.forEach { $0.schoolyear = first }; context.delete($0)}
            }
            context.saveCustom()
        }
    }
    
}
