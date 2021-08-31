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
}
