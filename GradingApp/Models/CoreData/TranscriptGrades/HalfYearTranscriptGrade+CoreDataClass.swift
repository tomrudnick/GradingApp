//
//  HalfYearTranscriptGrade+CoreDataClass.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//
//

import Foundation
import CoreData

@objc(HalfYearTranscriptGrade)
public class HalfYearTranscriptGrade: TranscriptGrade {
    
    override func getTranscriptGradeHalfValue(half: HalfType) -> Int?{
        return self.half == half ? Int(value) : nil
    }
    override func setTranscriptGradeHalfValue(half: HalfType, value: Int) throws {
        guard self.half == half else {
            throw HalfError.wrongHalf
        }
        self.value = Int32(value)
    }
    
    override func getCalculatedValue() -> Double {
        return Double(self.value)
    }
    
    convenience init(context: NSManagedObjectContext, half: HalfType) {
        self.init(context: context)
        self.half = half
    }
}
