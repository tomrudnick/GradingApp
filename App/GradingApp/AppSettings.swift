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
    @CloudStorage(HalfYearDateKeys.selectedHalf)    var activeHalf            :     HalfType = .firstHalf
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
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        if let activeSchoolYearUD, let activeSchoolYearUUID = UUID(uuidString: activeSchoolYearUD) {
            context.perform { [self] in
                activeSchoolYear = try? context.fetch(SchoolYear.fetchSchoolYear(id: activeSchoolYearUUID)).first
                
                if activeSchoolYear == nil {
                    activeSchoolYear = SchoolYear(name: "TEMP", context: PersistenceController.shared.container.viewContext)
                    self.activeSchoolYearUD = activeSchoolYear?.id.uuidString
                    context.saveCustom()
                }
            }
        } else { //THIS means that probably no schoolYear exists
            activeSchoolYear = SchoolYear(name: "TEMP", context: PersistenceController.shared.container.viewContext)
            activeSchoolYearUD = activeSchoolYear?.id.uuidString
            context.saveCustom()
        }
    }
    
    var correctHalf: Bool {
        (activeHalf == .firstHalf && Date() >= dateFirstHalf || activeHalf == .secondHalf && Date() >= dateSecondHalf)
    }
    
    func courseFetchRequest() -> NSFetchRequest<Course> {
        if let activeSchoolYear {
            print("ACTIVE SCHOOLYEAR name: \(activeSchoolYear.name)")
            return Course.fetchHalfNonHiddenSchoolYear(half: activeHalf, schoolYear: activeSchoolYear)
        } else {
            return Course.fetchHalfNonHidden(half: activeHalf)
        }
        
    }
    
}
