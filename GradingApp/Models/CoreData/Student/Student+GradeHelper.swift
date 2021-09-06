//
//  Student+GradeHelper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.08.21.
//

import Foundation


extension Student {
    
    func gradeCount (_ type: GradeType, half: HalfType) -> Int {
        return grades.filter { $0.type == type && $0.half == half }.count
    }
    
    func gradesExist (_ type: GradeType, half: HalfType) -> Bool {
        let filteredGrades = grades.filter { $0.type == type && $0.half == half }
        if filteredGrades.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    func gradesExist (half: HalfType) -> Bool {
        let filteredGrades = grades.filter { $0.half == half }
        if filteredGrades.count == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    
    func gradeAverage(type: GradeType, half: HalfType) -> Double {
        let filteredGrades = grades.filter { $0.type == type && $0.half == half }
        if filteredGrades.count == 0 {
            return -1
        }
        let sum = filteredGrades.reduce(0) { result, grade in
            result + Double(grade.value) //* grade.multiplier
        }
        let count = filteredGrades.reduce(0) { result, grade in
            result + grade.multiplier
        }
        return Double(sum) / Double(count)
    }
    
    
    
    func totalGradeAverage(half: HalfType) -> Double {
        if gradesExist(.oral, half: half) && gradesExist(.written, half: half) {
            let oralWeight = Double(self.course!.oralWeight)/100
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
    
    func getRoundedGradeAverage(_ type: GradeType, half: HalfType) -> String {
        if gradesExist(type, half: half) {
            switch self.course!.ageGroup {
            case .lower:
                return Grade.convertGradePointsToGrades(value: Grade.roundPoints(points: gradeAverage(type: type, half: half)))
            case .upper:
                return String(Grade.roundPoints(points: gradeAverage(type: type, half: half)))
            }
        } else {
            return "-"
        }
    }
    
    func getRoundedGradeAverage(half: HalfType) -> String {
        if gradesExist(half: half) {
            switch self.course!.ageGroup {
            case .lower:
                return Grade.convertGradePointsToGrades(value: Grade.roundPoints(points: totalGradeAverage(half: half)))
            case .upper:
                return String(Grade.roundPoints(points: totalGradeAverage(half: half)))
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
    
    func getSimpleGradeAverage(_ type: GradeType, half: HalfType) -> String {
        let average = self.gradeAverage(type: type, half: half)
        let floorAverage = Int(floor(average))
        switch self.course?.ageGroup {
        case .lower:
            return Grade.convertGradePointsToGrades(value: floorAverage)
        case .upper:
            return String(floorAverage)
        case .none:
            return "-"
        }
    }
    
    func getSimpleGradeAverage(half: HalfType) -> String {
        let average = Int(self.totalGradeAverage(half: half))
        switch self.course?.ageGroup {
        case .lower:
            return Grade.convertGradePointsToGrades(value: average)
        case .upper:
            if average == -1 {
                return "-"
            } else {
                return String(average)
            }
        case .none:
            return "-"
        }
    }
}
