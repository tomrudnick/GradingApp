//
//  GraphData.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import Foundation

struct GraphData: Identifiable {
    var id = UUID()
    
    var label: String {
        String(grade)
    }
    
    var grade: Int
    var value: CGFloat
    
    mutating func rounding025() {
        self.value = round(value * 4.0) / 4.0
    }
}
