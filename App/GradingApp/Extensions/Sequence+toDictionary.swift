//
//  Sequence+toDictionary.swift
//  GradingApp
//
//  Created by Tom Rudnick on 18.11.22.
//

import Foundation

extension Sequence {
    public func toDictionary<K: Hashable, V>(_ selector: (Iterator.Element) throws -> (K, V)?) rethrows -> [K: V] {
        var dict = [K: V]()
        for element in self {
            if let (key, value) = try selector(element) {
                dict[key] = value
            }
        }

        return dict
    }
}
