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
    
    private enum CodingKeys: String, CodingKey {case value, half}
    
    override func getTranscriptGradeHalfValue(half: HalfType) -> Int?{
        return self.half == half ? Int(value) : nil
    }
    override func setTranscriptGradeHalfValue(half: HalfType, value: Int) throws {
        guard self.half == half else {
            throw HalfError.wrongHalf
        }
        self.value = Int32(value)
    }
    
    override func getEduValue(half: HalfType) -> Int? {
        return self.half == half ? Int(value) : nil
    }
    
    override func setEduValue(half: HalfType, value: Int) throws {
        guard self.half == half else { throw HalfError.wrongHalf }
        self.eduValue = Int32(value)
    }
    
    override func getCalculatedValue() -> Double {
        return Double(self.value)
    }
    
    convenience init(context: NSManagedObjectContext, half: HalfType) {
        self.init(context: context)
        self.half = half
    }
    
    override public func encode(to encoder: Encoder) throws {
        //print("ENCODE HalfYearTranscriptGrade")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(half.rawValue, forKey: .half)
    }
    
    required public convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        half = try! container.decode(HalfType.self, forKey: .half)
        value = try! container.decode(Int32.self, forKey: .value)
    }
}
