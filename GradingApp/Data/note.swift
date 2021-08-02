//
//  noten.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 17.07.21.
//

import Foundation

class Note: ObservableObject, Identifiable {
    
    var NotenId = UUID().uuidString
    var notenDatum = Date()
    var notenTyp = ""
    var notenWert = ""
}
