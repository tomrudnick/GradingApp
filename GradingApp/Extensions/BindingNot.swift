//
//  BindingNot.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.01.22.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
