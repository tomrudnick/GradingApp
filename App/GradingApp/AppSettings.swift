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
                }
            }
        } else { //THIS means that probably no schoolYear exists
            createDefaultSchoolYear()
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
    
    private func createDefaultSchoolYear() {
        let context = PersistenceController.shared.container.viewContext
        let year = Calendar.current.component(.year, from: Date()) % 100
        let scholYearName = String(format: "%02d", year)+"/"+String(format: "%02d", year+1)
        activeSchoolYear = SchoolYear(name: scholYearName, context: PersistenceController.shared.container.viewContext)
        activeSchoolYearUD = activeSchoolYear?.id.uuidString
        context.saveCustom()
    }
    
}
