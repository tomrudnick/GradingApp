//
//  Rounded.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.08.21.
//

import Foundation

extension Double {
    func round(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}
