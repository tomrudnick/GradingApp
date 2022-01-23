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
public class TranscriptGrade: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey { case type }
    
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
    
    required public convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
    }
    public func encode(to encoder: Encoder) throws {
        preconditionFailure("Only use the overriden function")
    }
    
}


public class TranscriptGradeDecodeWrapper: Codable {
    private enum CodingKeys: String, CodingKey { case type, transcriptGrade }
    let transcriptGrade: TranscriptGrade?
    
    required public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try! container.decode(String.self, forKey: .type)
        if type == "fullYear" {
            self.init(transcriptGrade: try! container.decode(FullYearTranscriptGrade.self, forKey: .transcriptGrade))
        } else {
            self.init(transcriptGrade: try! container.decode(HalfYearTranscriptGrade.self, forKey: .transcriptGrade))
        }
    }
    
    init(transcriptGrade: TranscriptGrade) {
        self.transcriptGrade = transcriptGrade
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if transcriptGrade is FullYearTranscriptGrade {
            try container.encode("fullYear",forKey: .type)
        } else {
            try container.encode("halfYear", forKey: .type)
        }
        try container.encode(transcriptGrade, forKey: .transcriptGrade)
    }
}


