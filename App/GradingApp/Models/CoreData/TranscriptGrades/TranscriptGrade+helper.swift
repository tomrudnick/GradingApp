//
//  TranscriptGrade+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 31.08.21.
//

import Foundation
import CoreData

extension TranscriptGrade {
    static func addTranscriptGradeWithHalfValue(courseType: CourseType, value: Int, half: HalfType, student: Student, context: NSManagedObjectContext) {
        let transcriptGrade: TranscriptGrade?
        switch courseType {
        case .firstHalf, .secondHalf:
            transcriptGrade = HalfYearTranscriptGrade(context: context, half: courseType == .firstHalf ? .firstHalf : .secondHalf)
        case .holeYear:
            transcriptGrade = FullYearTranscriptGrade(context: context)
        }
        do {
            try transcriptGrade?.setTranscriptGradeHalfValue(half: half, value: value)
        } catch {
            fatalError("Failed adding Transcript grade \(error)")
        }
        transcriptGrade?.student = student
        context.saveCustom()
    }
}
