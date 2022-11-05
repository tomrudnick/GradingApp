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
    
    var sortedParticipants: [(student: Student, participant: Bool)] {
        participants.sorted { s1, s2 in
            Student.compareStudents(s1.key, s2.key)
        }.map { (student: $0.key, participant: $0.value)}
    }
    
    var sortedParticipatingStudents: [Student]  {
        sortedParticipants.filter(\.participant).map(\.student)
    }
    
    
    func initVM(course: Course) {
        self.course = course
        self.participants = Dictionary(uniqueKeysWithValues: course.students.map { ($0, true) })
        resetToDefaultGradeSchema()
        self.standardGradeScheme = gradeSchema
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
        var percentage = (getTotalPoints(for: student) / getMaxPointsPossible()) * 100
        if percentage.isNaN { percentage = 0.0 }
        for grade in gradeSchema.reversed() {
            if percentage >= grade.value {
                return Int(grade.label) ?? -1
            }
        }
        return Int(gradeSchema.first?.label ?? "-1") ?? -1
    }
    
    func getAverage() -> Double {
        let totalParticipants = self.participants.filter(\.value).count
        var sum = 0
        for grade in gradeSchema {
            sum += Int(grade.label)! * getNumberOfGrades(for: Int(grade.label)!)
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
        let percentage = Double(getNumberOfGrades(for: [1,2,3,4])) / Double(participants.filter(\.value).count)
        if percentage.isNaN { return 0.0 }
        return percentage * 100.0
    }
    
    func getChartData() -> [GraphData] {
        self.gradeSchema.map { grade in
            GraphData(label: grade.label, value: CGFloat(getNumberOfGrades(for: Int(grade.label)!)))
        }
    }
    
    func resetToDefaultGradeSchema() {
        self.gradeSchema = [GraphData(label: "1", value: 92.0),
                            GraphData(label: "2", value: 73.0),
                            GraphData(label: "3", value: 64.0),
                            GraphData(label: "4", value: 51.0),
                            GraphData(label: "5", value: 32.0),
                            GraphData(label: "6", value: 0.0)].reversed()
    }

    
    ///This private method returns the next title according to the standard scheme of matthias
    private func getNextTitle() -> String {
        "A\(self.exercises.count + 1)"
    }
    
    
    class ExerciseVM : ObservableObject, Hashable {
        var id: UUID
        @Published var title: String
        @Published var maxPointsText: String = "0" {
            didSet {
                let filtered = maxPointsText.filter { "0123456789.".contains($0) }
                if filtered != maxPointsText {
                    self.maxPointsText = filtered
                }
            }
        }
        @Published var participations: [ExerciseParticipationVM] = []
        
        
        var maxPoints: Double {
            get { Double(maxPointsText) ?? 0.0 }
            set { maxPointsText = String(format: "%.2f", newValue) }
        }
        
        init(id: UUID = UUID(), title: String, maxPoints: Double, participations: [ExerciseParticipationVM]) {
            self.title = title
            self.id = id
            self.maxPoints = maxPoints
            self.participations = participations
        }
        
       
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: ExamViewModel.ExerciseVM, rhs: ExamViewModel.ExerciseVM) -> Bool {
            lhs.id == rhs.id
        }
        

    }
    
    class ExerciseParticipationVM: ObservableObject {
        var student: Student
        
        var points: Double? {
            get {
                Double(pointsText)
            }
            
            set {
                if let newValue {
                    pointsText = String(format: "%.2f", newValue)
                } else {
                    pointsText = "-"
                }
                
            }
        }
        
        @Published var pointsText: String = "-" {
            didSet {
                let filtered = pointsText.filter { "0123456789.-".contains($0) }
                if filtered != pointsText {
                    self.pointsText = filtered
                }
            }
        }
        
        
        init(student: Student) {
            self.student = student
        }
        
        func checkMax(maxPoints: Double) {
            print("Check Max: \(maxPoints) for current Value \(self.pointsText)")
            guard let convertedValue = Double(self.pointsText) else { self.pointsText = "-"; return }
            if convertedValue > maxPoints {
                self.pointsText = "-"
            }
        }
    }
}
