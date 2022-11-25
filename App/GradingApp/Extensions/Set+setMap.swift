//
//  Set+setMap.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.11.22.
//

import Foundation

extension Set {
    func setmap<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}
