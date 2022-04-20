//
//  GradePickerViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import Foundation

class GradePickerViewModel: ObservableObject {
    
    enum GradePickerSetupOptions {
        case normal
        case transcript
    }
    
    @Published private(set) var pickerValues: [String]
    private(set) var translateToInt : (_ gradeString: String) -> (Int)
    private(set) var translateToString : (_ grade: Int) -> (String)
    
    init() {
        pickerValues = []
        translateToInt = { _ in -1 }
        translateToString = { _ in "-" }
    }
    
    func setup(courseType: AgeGroup, options: GradePickerSetupOptions) {
        if courseType == .lower && options == .normal {
            pickerValues = Grade.lowerSchoolGrades
            translateToInt = { gradeString in
                Grade.lowerSchoolGradesTranslate[gradeString]!
            }
            translateToString = Grade.convertGradePointsToGrades
        } else if courseType == .lower && options == .transcript {
            pickerValues = Grade.lowerSchoolTranscriptGrades
            translateToInt = { gradeString in
                Grade.lowerSchoolGradesTranslate[gradeString]!
            }
            translateToString = Grade.convertGradePointsToGrades
        } else if courseType == .upper {
            pickerValues = Grade.uppperSchoolGrades
            translateToInt = { gradeString in
                Int(gradeString) ?? -1
            }
            translateToString = { grade in grade == -1 ? "-" : String(grade) }
        }
    }
}
