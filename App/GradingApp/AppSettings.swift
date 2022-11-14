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
import CloudKit

class AppSettings : ObservableObject {
    @CloudStorage(HalfYearDateKeys.selectedHalf)    var activeHalf            :     HalfType = .firstHalf {
        didSet {
            correctHalf = (activeHalf == .firstHalf && Date() >= dateFirstHalf || activeHalf == .secondHalf && Date() >= dateSecondHalf)
        }
    }
    @CloudStorage(HalfYearDateKeys.firstHalf)       var dateFirstHalf         :     Date = Date()
    @CloudStorage(HalfYearDateKeys.secondHalf)      var dateSecondHalf        :     Date = Date()
    @CloudStorage("Schuljahr")                      var activeSchoolYearUD    :     String? {
        didSet {
            print("DID_SET")
            if let activeSchoolYearUD, let activeSchoolYearUUID = UUID(uuidString: activeSchoolYearUD) {
                let context = PersistenceController.shared.container.viewContext
                context.perform { [self] in
                    activeSchoolYear = try? context.fetch(SchoolYear.fetchSchoolYear(id: activeSchoolYearUUID)).first
                }
            }
        }
    }
    @Published var activeSchoolYear : SchoolYear?
    @Published var correctHalf: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        if let activeSchoolYearUD, let activeSchoolYearUUID = UUID(uuidString: activeSchoolYearUD) {
            context.perform { [self] in
                activeSchoolYear = try? context.fetch(SchoolYear.fetchSchoolYear(id: activeSchoolYearUUID)).first
                
                if activeSchoolYear == nil { //In theory this should never happen but while developing this might happen and this will prevent that the app crashes
                    createDefaultSchoolYear()
                    if let activeSchoolYear = self.activeSchoolYear {
                        addExistingCoursesToNewlyCreatedSchoolYear(schoolYear: activeSchoolYear)
                    }
                }
            }
        } else { //THIS means that probably no schoolYear exists
            context.perform { [self] in
                let uuid = getDefaultUUID()
                self.activeSchoolYear = try? context.fetch(SchoolYear.fetchSchoolYear(id: uuid)).first
                if self.activeSchoolYear != nil {
                    self.activeSchoolYearUD = uuid.uuidString
                } else {
                    self.createDefaultSchoolYear()
                }
                if let activeSchoolYear = self.activeSchoolYear {
                    addExistingCoursesToNewlyCreatedSchoolYear(schoolYear: activeSchoolYear)
                }
            }
        }
        
        correctHalf = (activeHalf == .firstHalf && Date() >= dateFirstHalf || activeHalf == .secondHalf && Date() >= dateSecondHalf)
    }
    
    
    func courseFetchRequest() -> NSFetchRequest<Course> {
        if let activeSchoolYear {
            print("ACTIVE SCHOOLYEAR name: \(activeSchoolYear.name)")
            return Course.fetchHalfNonHiddenSchoolYear(half: activeHalf, schoolYear: activeSchoolYear)
        } else {
            return Course.fetchHalfNonHidden(half: activeHalf)
        }
        
    }
    
    private func addExistingCoursesToNewlyCreatedSchoolYear(schoolYear: SchoolYear) {
        let context = PersistenceController.shared.container.viewContext
        context.perform {
            let courses = try? context.fetch(Course.fetchAllWithoutSchoolYear())
            guard let courses else { return }
            courses.forEach { $0.schoolyear = schoolYear }
            context.saveCustom()
        }
    }
    
    private func getDefaultUUID() -> UUID {
        return UUID(uuidString: "52D267B3-32A0-4797-8888-2281937C976F")!
    }
    
    private func createDefaultSchoolYear() {
        let context = PersistenceController.shared.container.viewContext
        let year = Calendar.current.component(.year, from: Date()) % 100
        let scholYearName = String(format: "%02d", year)+"/"+String(format: "%02d", year+1)
        let uuid = getDefaultUUID()
        activeSchoolYear = SchoolYear(name: scholYearName, context: PersistenceController.shared.container.viewContext, uuid: uuid)
        activeSchoolYearUD = activeSchoolYear?.id.uuidString
        context.saveCustom()
    }
    
}


