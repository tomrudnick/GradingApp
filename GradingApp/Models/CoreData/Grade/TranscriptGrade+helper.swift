//
//  TranscriptGrade+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 28.08.21.
//

import Foundation
import CoreData

extension HalfYearTranscriptGrade {
    var half: HalfType {
        get { HalfType(rawValue: half_)!}
        set { half_ = newValue.rawValue }
    }
}


protocol TranscriptGradeProtocol {
    func getTranscriptValueString() -> String
    func getTranscriptSetKeyPath() -> KeyPath<TranscriptGrade, Int>
}

extension HalfYearTranscriptGrade : TranscriptGradeProtocol {
    func getTranscriptValueString() -> String {
        return "\(half == .firstHalf ? "1. " : "2. ") Halbjahr Note: \(value)"
    }
    
    func getTranscriptSetKeyPath() -> KeyPath<TranscriptGrade, Int> {
        <#code#>
    }
    
    
}
