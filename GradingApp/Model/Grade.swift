//
//  noten.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 17.07.21.
//

import Foundation

struct Grade: Identifiable {
    
    var id = UUID().uuidString
    var date: Date
    var type: GradeType
    var value: Int
    
    //This Function needs to be rewritten
    static func convertStringToInt(grade: String) -> Int {
        return Int(grade.filter("0123456789.".contains)) ?? 0
    }
}

enum GradeType {
    case oral
    case written
}
