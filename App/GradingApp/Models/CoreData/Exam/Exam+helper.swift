//
//  Exam+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import Foundation
import UIKit
import CoreData


extension Exam {
    var date: Date {
        get { date_ ?? Date() }
        set { date_ = newValue }
    }
    
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    var gradeSchema: Dictionary<Int, Double> {
        get { gradeSchema_ as? Dictionary<Int, Double> ?? [:] }
        set { gradeSchema_ = NSDictionary(dictionary: newValue) }
    }
    
    var exercises: Set<ExamExercise> {
        get { exercises_ as? Set<ExamExercise> ?? [] }
        set { exercises_ = newValue as NSSet }
    }
    
    var examParticipations: Set<ExamParticipation> {
        get { examParticipations_ as? Set<ExamParticipation> ?? [] }
        set { examParticipations_ = newValue as NSSet }
    }
    
    var exercisesArr: Array<ExamExercise> {
        exercises.sorted { $0.index < $1.index }
    }
    
    var participations: Array<ExamParticipation> {
        examParticipations.sorted { p1, p2 in
            guard let s1 = p1.student, let s2 = p2.student else { return false } ///This Case should not occur
            return Student.compareStudents(s1, s2)
        }
    }
    
    var sortedParticipatingStudents: Array<Student> {
        examParticipations.filter(\.participated).compactMap(\.student).sorted(by: Student.compareStudents)
    }
    
    var failedGrades: [Int] {
        guard let course else { return [] }
        return course.ageGroup == .upper ? [0,1,2,3,4] : [6,5]
    }
    
    var passedGrades: [Int] {
        guard let course else { return [] }
        return course.ageGroup == .upper ? [5,6,7,8,9,10,11,12,13,14,15] : [4,3,2,1]
    }
    
    func addExercise(name: String? = nil, maxPoints: Double) {
        guard let context = self.managedObjectContext else { return }
        let name = name ?? getNextTitle()
        
        var exercise = ExamExercise(context: context)
        exercise.maxPoints = maxPoints
        exercise.name = name
        exercise.index = Int32(self.exercises.count)
        
        self.exercises.insert(exercise)
    }
    
    // TODO: Implement those functions somehow
    func delete(at offsets: IndexSet) {
        //exercises.remove(atOffsets: offsets)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        //exercises.move(fromOffsets: source, toOffset: destination)
    }
    
    func toggleParticipation(for student: Student) {
        examParticipations.first { $0.student == student }?.participated.toggle()
    }
    
    func getTotalPoints(for student: Student) -> Double {
        return exercises.flatMap { $0.participationExercises.filter { $0.examParticipation?.student == student } }
                        .compactMap { $0.points }
                        .reduce(0.0) { $0 + $1 }
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
        let gradeSchema = gradeSchema.sorted { $0.key < $1.key }
        for i in (0..<gradeSchema.count).reversed() {
            let minValue = round(Double(gradeSchema[i].value / 100.0) * maxPoints * 2.0) / 2.0
            if i < (gradeSchema.count - 1) {
                let maxValue = round(Double(gradeSchema[i + 1].value / 100.0) * maxPoints * 2.0) / 2.0
                let leftBoundType: RangeCustom<Double>.BoundType = i == 0 ? .closed : .half
                let range = RangeCustom(leftBound: minValue, leftType: leftBoundType, rightBound: maxValue, rightType: .closed)
                pointsToGrade.append((grade: gradeSchema[i].key, range: range))
            } else {
                let range = RangeCustom(leftBound: minValue, leftType: .half, rightBound: maxPoints, rightType: .closed)
                pointsToGrade.append((grade: gradeSchema[i].key, range: range))
            }
        }
        return pointsToGrade
    }
    
    func getAverage() -> Double {
        let totalParticipants = self.examParticipations.filter(\.participated).count
        var sum = 0
        for g in gradeSchema {
            sum += g.key * getNumberOfGrades(for: g.key)
        }
        return Double(sum) / Double(totalParticipants)
    }
    
    func getNumberOfGrades(for grade: Int) -> Int {
        return examParticipations.filter(\.participated)
                                 .compactMap { $0.student }
                                 .map { getGrade(for: $0) }
                                 .filter { $0 == grade }
                                 .count
    }
    
    
    func getNumberOfGrades(for grades: [Int]) -> Int {
        return examParticipations.filter(\.participated)
                                 .compactMap { $0.student }
                                 .map { getGrade(for: $0) }
                                 .filter { grades.contains($0) }
                                 .count
    }
    
    func getPercentageOfGrades(for grades: [Int]) -> Double {
        let percentage = Double(getNumberOfGrades(for: grades)) / Double(examParticipations.filter(\.participated).count)
        if percentage.isNaN { return 0.0 }
        return percentage * 100.0
    }
    
    func getPercentageOfPassed() -> Double {
        getPercentageOfGrades(for: passedGrades)
    }
    
    ///This private method returns the next title according to the standard scheme of matthias
    private func getNextTitle() -> String {
        "A\(self.exercises.count + 1)"
    }
}
