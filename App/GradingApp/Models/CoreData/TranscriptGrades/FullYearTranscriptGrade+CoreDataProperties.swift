//
//  FullYearTranscriptGrade+CoreDataProperties.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//
//

import Foundation
import CoreData


extension FullYearTranscriptGrade {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FullYearTranscriptGrade> {
        return NSFetchRequest<FullYearTranscriptGrade>(entityName: "FullYearTranscriptGrade")
    }

    @NSManaged public var firstValue: Int32
    @NSManaged public var secondValue: Int32
    @NSManaged public var firstEduValue: Int32
    @NSManaged public var secondEduValue: Int32

}
