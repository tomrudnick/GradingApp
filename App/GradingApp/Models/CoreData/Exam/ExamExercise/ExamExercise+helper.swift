//
//  ExamExercise+helper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.11.22.
//

import Foundation

extension ExamExercise {
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
    
    var participationExercises: Set<ExamParticipationExercise> {
        get { participationExercises_ as? Set<ExamParticipationExercise> ?? [] }
        set { participationExercises_ = newValue as NSSet }
    }
    
    func averagePoints() -> Double {
        //Summe der erreicht Punkte / Schüleranzahl * Aufgabenpunkt *100 gerundet
        let students = self.exam?.sortedParticipatingStudents ?? []
        let sumOfPoints = participationExercises
                          .filter {
                                if let student = $0.examParticipation?.student { return students.contains(student) }
                                return false
                          }.reduce(0.0) { $0 + $1.points }
        let divisor = maxPoints * Double(students.count)
        return divisor > 0.0 ? (sumOfPoints / divisor) * 100.0 : 0.0
    }
}
