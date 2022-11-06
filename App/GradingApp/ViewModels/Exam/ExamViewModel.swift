//
//  ExamViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import Foundation
import CoreData
import Combine

class ExamViewModel: ObservableObject {
    private var course: Course? ///Do not expose this variable to the outside
    @Published var date: Date = Date()
    @Published var title: String = ""
    @Published var gradeSchema: [GraphData] = []
    @Published var exercises: [ExerciseVM] = []
    @Published var participants: [Student : Bool] = [:]
    
    private(set) var standardGradeScheme: [GraphData] = []
    private(set) var failAtGrade: Int = -1
    
    var sortedParticipants: [(student: Student, participant: Bool)] {
        participants.sorted { s1, s2 in
            Student.compareStudents(s1.key, s2.key)
        }.map { (student: $0.key, participant: $0.value)}
    }
    
    var sortedParticipatingStudents: [Student]  {
        sortedParticipants.filter(\.participant).map(\.student)
    }
    
    var failedGrades: [Int] {
        guard let course else { return [] }
        return course.ageGroup == .upper ? [0,1,2,3,4] : [6,5]
    }
    
    var passedGrades: [Int] {
        guard let course else { return [] }
        return course.ageGroup == .upper ? [5,6,7,8,9,10,11,12,13,14,15] : [4,3,2,1]
    }
    
    func initVM(course: Course) {
        self.course = course
        self.participants = Dictionary(uniqueKeysWithValues: course.students.map { ($0, true) })
        resetToDefaultGradeSchema()
        self.standardGradeScheme = gradeSchema
        self.failAtGrade = course.ageGroup == .upper ? 4 : 2
    }
    
    func addExercise(title: String? = nil, maxPoints: Double) {
        let title = title ?? getNextTitle()
        let participations = participants.filter{ $0.value }.map{ ExerciseParticipationVM(student: $0.key)}
        let exercise = ExerciseVM(title: title, maxPoints: maxPoints, participations: participations)
        exercises.append(exercise)
    }
    
    func delete(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    func toggleParticipation(for student: Student) {
        participants[student]?.toggle()
    }
    
    func getTotalPoints(for student: Student) -> Double {
        return exercises.flatMap { $0.participations.filter { $0.student == student } }.compactMap { $0.points }.reduce(0.0) { $0 + $1 }
    }
    
    func getMaxPointsPossible() -> Double {
        return exercises.reduce(0.0) { $0 + $1.maxPoints }
    }
    
    func getGrade(for student: Student) -> Int {
        let points = getTotalPoints(for: student)
        let gradeToPoints = getPointsToGrade()
        for gradeInterval in gradeToPoints {
            if gradeInterval.range.contains(value: points) {
                return gradeInterval.grade
            }
        }
        return gradeToPoints.last?.grade ?? -1
    }
    

    
    func getPointsToGrade() -> [(grade: Int, range: RangeCustom<Double>)]  {
        var pointsToGrade: [(grade: Int, range: RangeCustom<Double>)] = []
        let maxPoints = getMaxPointsPossible()
        for i in (0..<gradeSchema.count).reversed() {
            let minValue = round(Double(gradeSchema[i].value / 100.0) * maxPoints * 2.0) / 2.0
            if i < (gradeSchema.count - 1) {
                let maxValue = round(Double(gradeSchema[i + 1].value / 100.0) * maxPoints * 2.0) / 2.0
                let leftBoundType: RangeCustom<Double>.BoundType = i == 0 ? .closed : .half
                let range = RangeCustom(leftBound: minValue, leftType: leftBoundType, rightBound: maxValue, rightType: .closed)
                pointsToGrade.append((grade: gradeSchema[i].grade, range: range))
            } else {
                let range = RangeCustom(leftBound: minValue, leftType: .half, rightBound: maxPoints, rightType: .closed)
                pointsToGrade.append((grade: gradeSchema[i].grade, range: range))
            }
        }
        return pointsToGrade
    }
    
    func getAverage() -> Double {
        let totalParticipants = self.participants.filter(\.value).count
        var sum = 0
        for g in gradeSchema {
            sum += g.grade * getNumberOfGrades(for: g.grade)
        }
        return Double(sum) / Double(totalParticipants)
    }
    
    func getNumberOfGrades(for grade: Int) -> Int {
        return participants.filter(\.value).map { getGrade(for: $0.key )}.filter { $0 == grade }.count
    }
    
    func getNumberOfGrades(for grades: [Int]) -> Int {
        return participants.filter(\.value).map { getGrade(for: $0.key )}.filter { grades.contains($0) }.count
    }
    
    func getPercentageOfGrades(for grades: [Int]) -> Double {
        let percentage = Double(getNumberOfGrades(for: grades)) / Double(participants.filter(\.value).count)
        if percentage.isNaN { return 0.0 }
        return percentage * 100.0
    }
    
    func getPercentageOfPassed() -> Double {
        getPercentageOfGrades(for: passedGrades)
    }
    
    func getChartData() -> [GraphData] {
        self.gradeSchema.map { data in
            GraphData(grade: data.grade, value: CGFloat(getNumberOfGrades(for: data.grade)))
        }
    }
    
    func resetToDefaultGradeSchema() {
        guard let course else { return }
        self.gradeSchema = course.ageGroup == .upper ? defaultGradeSchemeUpperCourse() : defaultGradeSchemeLowerCourse()
    }

    
    ///This private method returns the next title according to the standard scheme of matthias
    private func getNextTitle() -> String {
        "A\(self.exercises.count + 1)"
    }
    
    private func defaultGradeSchemeLowerCourse() -> [GraphData] {
        return [GraphData(grade: 1, value: 87.5),
                GraphData(grade: 2, value: 75.0),
                GraphData(grade: 3, value: 62.5),
                GraphData(grade: 4, value: 50.0),
                GraphData(grade: 5, value: 20.0),
                GraphData(grade: 6, value: 0.0)].reversed()
    }
    
    private func defaultGradeSchemeUpperCourse() -> [GraphData] {
        return [GraphData(grade: 15, value: 95.0),
                GraphData(grade: 14, value: 90.0),
                GraphData(grade: 13, value: 85.0),
                GraphData(grade: 12, value: 80.0),
                GraphData(grade: 11, value: 75.0),
                GraphData(grade: 10, value: 70.0),
                GraphData(grade: 9,  value: 65.0),
                GraphData(grade: 8,  value: 60.0),
                GraphData(grade: 7,  value: 55.0),
                GraphData(grade: 6,  value: 50.0),
                GraphData(grade: 5,  value: 45.0),
                GraphData(grade: 4,  value: 40.0),
                GraphData(grade: 3,  value: 33.0),
                GraphData(grade: 2,  value: 27.0),
                GraphData(grade: 1,  value: 20.0),
                GraphData(grade: 0,  value: 0.0),
        ].reversed()
    }
}


struct RangeCustom<T: Comparable>: CustomStringConvertible {
    enum BoundType {
        case half, closed
    }
    
    let leftBound: T
    let leftType: BoundType
    
    let rightBound: T
    let rightType: BoundType
    
    var description: String {
        let left = leftType == .closed ? "[" : "("
        let right = rightType == .closed ? "]" : ")"
        return "\(left)\(leftBound), \(rightBound)\(right)"
    }
    
    func contains(value: T) -> Bool {
        let leftSide = leftType == .closed ? leftBound <= value : leftBound < value
        let rightSide = rightType == .closed ? value <= rightBound : value < rightBound
        return leftSide && rightSide
    }
}
