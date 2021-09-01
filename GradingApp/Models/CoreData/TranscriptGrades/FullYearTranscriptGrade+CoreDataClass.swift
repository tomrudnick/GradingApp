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
    
    override func getCalculatedValue() -> Double {
        if firstValue == -1 && secondValue == -1{
            return -1.0
        } else if firstValue == -1 {
            return Double(secondValue)
        } else if secondValue == -1 {
            return Double(firstValue)
        } else {
            return (Double(firstValue) + Double(secondValue)) / 2.0
        }
    }
}
