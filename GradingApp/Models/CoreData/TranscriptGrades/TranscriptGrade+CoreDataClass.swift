//
//  TranscriptGrade+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//
//

import Foundation
import CoreData

@objc(TranscriptGrade)
public class TranscriptGrade: NSManagedObject {
    enum HalfError: Error {
        case wrongHalf
    }
    func getTranscriptGradeHalfValue(half: HalfType) -> Int?{
        preconditionFailure("Only use the overriden function")
    }
    func setTranscriptGradeHalfValue(half: HalfType, value: Int) throws {
        preconditionFailure("Only use the overriden function")
    }
    
    func getCalculatedValue() -> Double {
        preconditionFailure("Only use the overriden function")
    }
    
    func getTranscriptGradeHalfValueString(half: HalfType) -> String {
        let value = getTranscriptGradeHalfValue(half: half)
        if let value = value {
            if value == -1 {
                return "-"
            }
            switch self.student?.course?.ageGroup {
            case .lower:
                return Grade.convertGradePointsToGrades(value: value)
            case .upper:
                return String(value)
            case .none:
                return "-"
            }
        } else {
            return "-"
        }
        
    }
    
    func getTranscriptGradeValueString() -> String {
        if value == -1 {
            return "-"
        }
        switch self.student?.course?.ageGroup {
        case .lower:
            return Grade.convertGradePointsToGrades(value: Int(value))
        case .upper:
            return String(Int(value))
        case .none:
            return "-"
        }
    }
    
    //convertGradePointsToGrades(value: Int(value)))
    
    func getCalculatedValueString() -> String {
        let value = getCalculatedValue()
        switch self.student?.course?.ageGroup {
        case .lower:
            return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: value))
        case .upper:
            return String(format: "%.1f", value)
        case .none:
            return "-"
        }
    }
    
}
