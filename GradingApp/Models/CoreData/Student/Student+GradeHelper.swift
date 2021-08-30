//
//  Student+GradeHelper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.08.21.
//

import Foundation


extension Student {
    func gradesExist (_ type: GradeType) -> Bool {
        let filteredGrades = grades.filter { $0.type == type }
        if filteredGrades.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    func gradesExist () -> Bool {
        if grades.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    
    func gradeAverage(type: GradeType) -> Double {
        let filteredGrades = grades.filter { $0.type == type }
        if filteredGrades.count == 0 {
            return -1
        }
        let sum = filteredGrades.reduce(0) { result, grade in
            result + Double(grade.value) * grade.multiplier
        }
        return Double(sum) / Double(filteredGrades.count)
    }
    
    
    
    func totalGradeAverage() -> Double {
        if gradesExist(.oral) && gradesExist(.written) {
            let oralWeight = Double(self.course!.oralWeight)/100
            let writtenWeight = 1 - oralWeight
            return oralWeight * gradeAverage(type: .oral) + writtenWeight * gradeAverage(type: .written)
        } else if gradesExist(.oral) && !gradesExist(.written) {
            return gradeAverage(type: .oral)
        } else if !gradesExist(.oral) && gradesExist(.written) {
            return gradeAverage(type: .written)
        } else {
            return -1
        }
    }
    
    func getRoundedGradeAverage(_ type: GradeType) -> String {
        if gradesExist(type) {
            switch self.course!.ageGroup {
            case .lower:
                return Grade.convertGradePointsToGrades(value: Grade.roundPoints(points: gradeAverage(type: type)))
            case .upper:
                return String(Grade.roundPoints(points: gradeAverage(type: type)))
            }
        } else {
            return "-"
        }
    }
    
    func getRoundedGradeAverage() -> String {
        if gradesExist() {
            switch self.course!.ageGroup {
            case .lower:
                return Grade.convertGradePointsToGrades(value: Grade.roundPoints(points: totalGradeAverage()))
            case .upper:
                return String(Grade.roundPoints(points: totalGradeAverage()))
            }
        } else {
            return "-"
        }
    }
    
    func getGradeAverage(_ type: GradeType) -> String {
        if gradesExist(type) {
            switch self.course!.ageGroup {
            case .lower:
                return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: gradeAverage(type: type)))
            case .upper:
                return String(format: "%.1f", self.gradeAverage(type: type))
            }
        } else {
            return "-"
        }
    }
    
    func getGradeAverage() -> String {
        if gradesExist() {
            switch self.course!.ageGroup {
            case .lower:
                return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: totalGradeAverage()))
            case .upper:
                return String(format: "%.1f", self.totalGradeAverage())
            }
        } else {
            return "-"
        }
    }
}
