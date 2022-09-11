//
//  SchoolYearViewModel.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 11.09.22.
//

import Foundation


class SchoolYearViewModel: ObservableObject{
    
    @Published var schoolYear : String?
   
    init() {
        schoolYear = NSUbiquitousKeyValueStore.default.string(forKey: "Schuljahr")
    }
    func update(newSchoolYear:String) {
        schoolYear = newSchoolYear
        NSUbiquitousKeyValueStore.default.set(newSchoolYear, forKey: "Schuljahr")
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
