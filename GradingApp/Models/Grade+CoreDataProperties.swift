//
//  Grade+CoreDataProperties.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//
//

import Foundation
import CoreData


extension Grade {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Grade> {
        return NSFetchRequest<Grade>(entityName: "Grade")
    }

    @NSManaged public var date: Date?
    @NSManaged public var half: HalfType
    @NSManaged public var type: GradeType
    @NSManaged public var value: Int32
    @NSManaged public var comment: String?
    @NSManaged public var multiplier: Double
    @NSManaged public var student: Student?

}

extension Grade : Identifiable {

}

@objc
public enum GradeType: Int16 {
    case oral
    case written
}

@objc
public enum HalfType: Int16 {
    case firstHalf
    case secondHalf
}

