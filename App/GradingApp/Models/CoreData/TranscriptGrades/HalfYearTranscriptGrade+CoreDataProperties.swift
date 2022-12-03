//
//  HalfYearTranscriptGrade+CoreDataProperties.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//
//

import Foundation
import CoreData


extension HalfYearTranscriptGrade {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HalfYearTranscriptGrade> {
        return NSFetchRequest<HalfYearTranscriptGrade>(entityName: "HalfYearTranscriptGrade")
    }

    @NSManaged public var half_: Int16
    @NSManaged public var eduValue: Int32

}

extension HalfYearTranscriptGrade {
    var half: HalfType {
        get { HalfType(rawValue: half_)!}
        set { half_ = newValue.rawValue }
    }
}

