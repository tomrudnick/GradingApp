//
//  Student+GradeHelper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.08.21.
//

import Foundation


extension Student {
    
    func gradeCount (_ type: GradeType, half: HalfType) -> Int {
        var gradesCount = grades.filter { $0.type == type && $0.half == half }.count
        if type == .written { gradesCount += examParticipations.filter { $0.participated }.count  }
        return gradesCount
    }
    
    func gradesExist (_ type: GradeType, half: HalfType) -> Bool {
        var gradesCount = grades.filter { $0.type == type && $0.half == half }.count
        if type == .written { gradesCount += examParticipations.filter { $0.participated }.count  }
        if gradesCount == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    func gradesExist (half: HalfType) -> Bool {
        var gradesCount = grades.filter { $0.half == half }.count
        gradesCount += examParticipations.filter { $0.participated }.count
        return gradesCount != 0
    }
    
    
    func gradeAverage(type: GradeType, half: HalfType) -> Double {
        let filteredGrades = grades.filter { $0.type == type && $0.half == half }
        var gradexExists: Bool = false
        var sum = 0.0
        var count = 0.0
        
        if filteredGrades.count > 0 {
            sum = filteredGrades.reduce(0) { result, grade in
                result + Double(grade.value) * grade.multiplier
            }
            count = filteredGrades.reduce(0) { result, grade in
                result + grade.multiplier
            }
            gradexExists = true
        }
       
        
        if type == .written {
            let filteredExams = examParticipations.filter { $0.exam?.half == half }
            if filteredExams.count > 0 {
                sum += filteredExams.reduce(0) { result, examPart in
                    result + Double(examPart.getGrade())
                }
                count += filteredExams.reduce(0) { result, examPart in
                    result + max((examPart.exam?.multiplier ?? 1.0),0.5)
                }
                gradexExists = true
            }
        }
        if gradexExists { return Double(sum) / Double(count) }
        else { return -1 }
    }
    
    
    
    func totalGradeAverage(half: HalfType) -> Double {
        if gradesExist(.oral, half: half) && gradesExist(.written, half: half) {
            let oralWeight = Double(self.course?.oralWeight ?? 0)/100
            let writtenWeight = 1 - oralWeight
            return oralWeight * gradeAverage(type: .oral, half: half) + writtenWeight * gradeAverage(type: .written, half: half)
        } else if gradesExist(.oral, half: half) && !gradesExist(.written, half: half) {
            return gradeAverage(type: .oral, half: half)
        } else if !gradesExist(.oral, half: half) && gradesExist(.written, half: half) {
            return gradeAverage(type: .written, half: half)
        } else {
            return -1
        }
    }
    //This Method is only to display the grade and not for futher calculations
    func getRoundedGradeAverage(_ type: GradeType, half: HalfType) -> String {
        if gradesExist(half: half) {
            let average = Int(round(self.gradeAverage(type: type, half: half)))
            switch self.course?.ageGroup {
            case .lower:
                return Grade.convertGradePointsToGrades(value: average)
            case .upper:
                return String(average)
            case .none:
                return "-"
            }
        } else {
            return "-"
        }
    }
    
    func getRoundedGradeAverage(half: HalfType) -> String {
        if gradesExist(half: half) {
            let average = Int(round(self.totalGradeAverage(half: half)))
            switch self.course?.ageGroup {
            case .lower:
                return Grade.convertGradePointsToGrades(value: average)
            case .upper:
                return String(average)
            case .none:
                return "-"
            }
        } else {
            return "-"
        }
    }
    
    func getGradeAverage(_ type: GradeType, half: HalfType) -> String {
        if gradesExist(type, half: half) {
            switch self.course?.ageGroup {
            case .lower:
                return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: gradeAverage(type: type, half: half)))
            case .upper:
                return String(format: "%.1f", self.gradeAverage(type: type, half: half))
            case .none:
                return "-"
            }
        } else {
            return "-"
        }
    }
    
    func getGradeAverage(half: HalfType) -> String {
        if gradesExist(half: half) {
            switch self.course?.ageGroup {
            case .lower:
                return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: totalGradeAverage(half: half)))
            case .upper:
                return String(format: "%.1f", self.totalGradeAverage(half: half))
            case .none:
                return "-"
            }
        } else {
            return "-"
        }
    }
}
