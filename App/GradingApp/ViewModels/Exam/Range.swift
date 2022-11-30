//
//  ExamViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import Foundation
import CoreData
import Combine


struct RangeCustom<T: Comparable>: CustomStringConvertible {
    enum BoundType {
        case half, closed
    }
    
    let leftBound: T
    let leftType: BoundType
    
    let rightBound: T
    let rightType: BoundType
    
    var description: String {
        let left = leftType == .closed ? "[" : "("
        let right = rightType == .closed ? "]" : ")"
        return "\(left)\(leftBound), \(rightBound)\(right)"
    }
    
    var studentDescription: String {
        return "\(rightBound) bis \(leftBound)"
    }
    
    func contains(value: T) -> Bool {
        let leftSide = leftType == .closed ? leftBound <= value : leftBound < value
        let rightSide = rightType == .closed ? value <= rightBound : value < rightBound
        return leftSide && rightSide
    }
}
