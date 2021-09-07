//
//  HalfYear+EnvironmentValue.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation
import SwiftUI

struct HalfYearKey: EnvironmentKey {
    static let defaultValue: HalfType = .firstHalf
}

extension EnvironmentValues {
    var currentHalfYear: HalfType {
        get { self[HalfYearKey.self] }
        set { self[HalfYearKey.self] = newValue }
    }
}
