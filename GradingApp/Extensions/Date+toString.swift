//
//  Date+toString.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import Foundation



extension Date {
    func asString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
