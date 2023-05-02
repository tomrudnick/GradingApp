//
//  Color+init.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.05.23.
//

import SwiftUI



#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }
}


extension Color {
    init(color: Color, opacity: CGFloat) {
        self.init(red: color.components.red, green: color.components.green, blue: color.components.blue, opacity: opacity)
    }
}
