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
    
    private enum CodingKeys: String, CodingKey {case firstValue, secondValue, value}
    
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
    
    override func getEduValue(half: HalfType) -> Int? {
        return half == .firstHalf ? Int(firstEduValue) : Int(secondEduValue)
    }
    
    override func setEduValue(half: HalfType, value: Int) {
        if half == .firstHalf {
            firstEduValue = Int32(value)
        } else {
            secondEduValue = Int32(value)
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
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(firstValue, forKey: .firstValue)
        try container.encode(secondValue, forKey: .secondValue)
    }
    
    required public convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try! container.decode(Int32.self, forKey: .value)
        firstValue = try! container.decode(Int32.self, forKey: .firstValue)
        secondValue = try! container.decode(Int32.self, forKey: .secondValue)
    }
}
