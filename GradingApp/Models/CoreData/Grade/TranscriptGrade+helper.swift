//
//  TranscriptGrade+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 28.08.21.
//

import Foundation
import CoreData

extension HalfYearTranscriptGrade {
    var half: HalfType {
        get { HalfType(rawValue: half_)!}
        set { half_ = newValue.rawValue }
    }
}
