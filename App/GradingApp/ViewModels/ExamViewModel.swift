//
//  ExamViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 03.11.22.
//

import Foundation
import CoreData

class ExamViewModel: ObservableObject {
    private var course: Course? ///Do not expose this variable to the outside
    @Published var date: Date = Date()
    @Published var title: String = ""
    @Published var gradeSchema: Dictionary<String, Int> = [:]
    @Published var exercises: [ExerciseVM] = []
    @Published var participants: [Student : Bool] = [:]
    
    var sortedParticipants: [(student: Student, participant: Bool)] {
        participants.sorted { s1, s2 in
            Student.compareStudents(s1.key, s2.key)
        }.map { (student: $0.key, participant: $0.value)}
    }
    
    
    func initVM(course: Course) {
        self.course = course
        self.participants = Dictionary(uniqueKeysWithValues: course.students.map { ($0, true) })
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
    
    ///This private method returns the next title according to the standard scheme of matthias
    private func getNextTitle() -> String {
        "A\(self.exercises.count + 1)"
    }
    
    
    class ExerciseVM : ObservableObject, Hashable {
        var id: UUID
        @Published var title: String
        @Published var maxPoints: Double = 0.0
        @Published var participations: [ExerciseParticipationVM] = []
        
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
        var points: Double = 0.0
        
        init(student: Student) {
            self.student = student
        }
    }
}
