//
//  HalfYear+EnvironmentValue.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation
import SwiftUI

struct HalfYear: EnvironmentKey {
    static var defaultValue: HalfType = .firstHalf
}

extension EnvironmentValues {
    var halfYear: HalfType {
        get { self[HalfYear.self] }
        set { self[HalfYear.self] = newValue }
    }
}
