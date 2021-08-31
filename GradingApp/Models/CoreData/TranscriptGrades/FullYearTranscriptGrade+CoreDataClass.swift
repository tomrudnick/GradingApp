//
//  FullYearTranscriptGrade+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//
//

import Foundation
import CoreData

@objc(FullYearTranscriptGrade)
public class FullYearTranscriptGrade: TranscriptGrade {
    override func getTranscriptGradeHalfValue(half: HalfType) -> Int?{
        return half == .firstHalf ? Int(firstValue) : Int(secondValue)
    }
    override func setTranscriptGradeHalfValue(half: HalfType, value: Int) throws {
        if half == .firstHalf {
            firstValue = Int32(value)
        } else {
            secondValue = Int32(value)
        }
    }
}
