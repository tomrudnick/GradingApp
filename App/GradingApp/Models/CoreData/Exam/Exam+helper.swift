//
//  Exam+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import Foundation
import UIKit
import CoreData
import SwiftUI

struct GradeCount: Identifiable {
    var id: Int {
        return grade_
    }
    
    var grade: String {
        String(grade_)
    }
    
    var number: String {
        String(number_)
    }
    
    let grade_: Int
    let number_: Int
}

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
    
    var gradeSchemaGraphData: [GraphData] {
        get {
            gradeSchema.sorted { gradeSchemeSort(v1: $0.key, v2: $1.key) }
                       .map { GraphData(grade: $0.key, value: $0.value )}
        }
        
        set { gradeSchema = newValue.toDictionary {($0.grade,$0.value)} }
    }
    
    var standardGradeSchemeGraphData: [GraphData] {
        get {
            (course?.ageGroup == .upper ? defaultGradeSchemeUpperCourse() : defaultGradeSchemeLowerCourse())
                .sorted { gradeSchemeSort(v1: $0.key, v2: $1.key) }
                .map { GraphData(grade: $0.key, value: $0.value )}
        }
    }
    
    var mapGradesToNumberOfOccurences: [GradeCount] {
        gradeSchema.keys.map { GradeCount(grade_: $0, number_: getNumberOfGrades(for: $0)) }
            .sorted { g1, g2 in
                gradeSchemeSort(v1: g1.grade_, v2: g2.grade_)
            }
    }
    
    var examParticipations: Set<ExamParticipation> {
        get { examParticipations_ as? Set<ExamParticipation> ?? [] }
        set { examParticipations_ = newValue as NSSet }
    }
    
    var exercisesArr: Array<ExamExercise> {
        exercises.sorted { $0.index < $1.index }
    }
    
    var participations: Array<ExamParticipation> {
        (examParticipations_ as? Set<ExamParticipation> ?? []).sorted { p1, p2 in
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
    
    func participationCount() -> Int {
        self.examParticipations.filter(\.participated).count
    }
    
    func setup(course: Course, half: HalfType) {
        guard let context = self.managedObjectContext else { return }
        
        self.course = PersistenceController.copyForEditing(of: course, in: context)
        self.date = Date()
        
        self.course?.students.forEach { student in
            print("Add: \(student.firstName)")
            _ = ExamParticipation(context: context, student: student, exam: self)
        }
        print(self.examParticipations.count)
        self.multiplier = 1.0
        self.half = half
        resetToDefaultGradeSchema()
    }
    
    func addExercise(name: String? = nil, maxPoints: Double) {
        guard let context = self.managedObjectContext else { return }
        let name = name ?? getNextTitle()
        
        let exercise = ExamExercise(context: context)
        exercise.maxPoints = maxPoints
        exercise.name = name
        exercise.index = Int32(self.exercises.count)
        
        self.exercises.insert(exercise)
        
        self.course?.students.forEach { student in
            guard let examP = student.examParticipations.first(where: { $0.exam == self }) else { return }
            
            _ = ExamParticipationExercise(exercise: exercise, examParticipation: examP, context: context)

        }
        
    }
    
    // TODO: Implement those functions somehow
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            guard let exercise = exercises.first(where: { $0.index == Int32(index) }) else { return }
            exercises.remove(exercise)
            managedObjectContext?.delete(exercise)
        }
        let arr = exercisesArr
        for (index, exercise) in arr.enumerated() {
            exercise.index = Int32(index)
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        var arr = exercisesArr
        arr.move(fromOffsets: source, toOffset: destination)
        for (index, exercise) in arr.enumerated() {
            if exercise.index != Int32(index) {
                exercise.index = Int32(index)
            }
        }
    }
    
    func toggleParticipation(for student: Student) {
        examParticipations.first { $0.student == student }?.participated.toggle()
    }
    
    func getTotalPoints(for student: Student) -> Double {
        return exercises.flatMap { $0.participationExercises.filter { $0.examParticipation?.student == student } }
                        .compactMap { $0.points }
                        .filter { $0 >= 0.0 }
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
        let gradeSchema: [Dictionary<Int, Double>.Element] = gradeSchema.sorted { gradeSchemeSort(v1: $0.key, v2: $1.key) }
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
    
    func getAverage2() -> (Double,Color) {
        let average = getAverage()
        var roundedAverage = Int(round(average))
        if course?.ageGroup == .lower {
            roundedAverage = Grade.convertLowerGradeToPoints(grade: roundedAverage)
        }
        return (average, Grade.getColor(points: Double(roundedAverage)))
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
    
    func getPercentageOfFailed() -> Double {
        getPercentageOfGrades(for: failedGrades)
    }
    
    func getChartData() -> [GraphData] {
        self.gradeSchemaGraphData.map { data in
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
    
    private func defaultGradeSchemeUpperCourse() -> Dictionary<Int, Double> {
        return [15 : 95.0,
                14 : 90.0,
                13 : 85.0,
                12 : 80.0,
                11 : 75.0,
                10 : 70.0,
                9  : 65.0,
                8  : 60.0,
                7  : 55.0,
                6  : 50.0,
                5  : 45.0,
                4  : 40.0,
                3  : 33.0,
                2  : 27.0,
                1  : 20.0,
                0  : 0.0
                ]
    }
    
    
    private func defaultGradeSchemeLowerCourse() -> Dictionary<Int, Double>  {
        return [1 : 87.5,
                2 : 75.0,
                3 : 62.5,
                4 : 50.0,
                5 : 20.0,
                6 : 0.0
                ]
    }
    
    private func gradeSchemeSort(v1: Int, v2: Int) -> Bool {
        if self.course?.ageGroup == .lower {
            return v1 > v2
        } else {
            return v1 < v2
        }
    }
    
    
}
