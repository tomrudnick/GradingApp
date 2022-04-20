//
//  TranscriptGrade+CoreDataProperties.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//
//

import Foundation
import CoreData


extension TranscriptGrade {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranscriptGrade> {
        return NSFetchRequest<TranscriptGrade>(entityName: "TranscriptGrade")
    }

    @NSManaged public var value: Int32
    @NSManaged public var student: Student?

}

extension TranscriptGrade : Identifiable {

}


