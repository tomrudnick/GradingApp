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
        var sum = filteredGrades.reduce(0) { result, grade in
            result + Double(grade.value) * grade.multiplier
        }
        var count = filteredGrades.reduce(0) { result, grade in
            result + grade.multiplier
        }
        
        if type == .written {
            let filteredExams = examParticipations.filter { $0.exam?.half == half }
            /*sum += filteredExams.reduce(0) { result, examPart in
                result +
            }*/
        }
        
        return Double(sum) / Double(count)
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
