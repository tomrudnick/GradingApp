//
//  GraphData.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.11.22.
//

import Foundation

struct GraphData: Identifiable {
    var id = UUID()
    var label: String
    var value: CGFloat
    
    mutating func rounding025() {
        var decimalValue = value.truncatingRemainder(dividingBy: 1.0)
        let pseudoIntValue = value - decimalValue
        
        switch decimalValue {
        case ..<0.125: decimalValue = 0.0
        case 0.125..<0.375: decimalValue = 0.25
        case 0.375..<0.625: decimalValue = 0.5
        case 0.625..<0.875: decimalValue = 0.75
        case 0.875...     : decimalValue = 1.0
        default:
            decimalValue = 0.0
        }
        value = decimalValue + pseudoIntValue
    }
}
