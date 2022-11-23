//
//  Exam+CoreDataProperties.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.11.22.
//
//

import Foundation
import CoreData


extension Exam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exam> {
        return NSFetchRequest<Exam>(entityName: "Exam")
    }

    @NSManaged public var date_: Date?
    @NSManaged public var gradeSchema_: NSObject? //This is unsafely converted to a dictionary
    @NSManaged public var name_: String?
    @NSManaged public var half: HalfType
    @NSManaged public var course: Course?
    @NSManaged public var examParticipations_: NSSet?
    @NSManaged public var exercises_: NSSet?
    @NSManaged public var multiplier: Double

}

// MARK: Generated accessors for examParticipations_
extension Exam {

    @objc(addExamParticipations_Object:)
    @NSManaged public func addToExamParticipations_(_ value: ExamParticipation)

    @objc(removeExamParticipations_Object:)
    @NSManaged public func removeFromExamParticipations_(_ value: ExamParticipation)

    @objc(addExamParticipations_:)
    @NSManaged public func addToExamParticipations_(_ values: NSSet)

    @objc(removeExamParticipations_:)
    @NSManaged public func removeFromExamParticipations_(_ values: NSSet)

}

// MARK: Generated accessors for exercises_
extension Exam {

    @objc(addExercises_Object:)
    @NSManaged public func addToExercises_(_ value: ExamExercise)

    @objc(removeExercises_Object:)
    @NSManaged public func removeFromExercises_(_ value: ExamExercise)

    @objc(addExercises_:)
    @NSManaged public func addToExercises_(_ values: NSSet)

    @objc(removeExercises_:)
    @NSManaged public func removeFromExercises_(_ values: NSSet)

}

extension Exam : Identifiable {

}
