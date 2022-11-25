//
//  Course+CoreDataClass.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 05.09.21.
//
//

import Foundation
import CoreData

@objc(Course)
public class Course: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey { case  subject, name, ageGroup, weight, type, hidden, students, exams}
    
    
    
    required public convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subject = try! container.decode(String.self, forKey: .subject)
        name = try! container.decode(String.self, forKey: .name)
        ageGroup = try! container.decode(AgeGroup.self, forKey: .ageGroup)
        weight_ = try! container.decode(Int32.self, forKey:.weight)
        type = try! container.decode(CourseType.self, forKey: .type)
        hidden = try! container.decode(Bool.self, forKey: .hidden)
        students = try! container.decode(Set<Student>.self, forKey: .students)
        exams = try! container.decode(Set<Exam>.self, forKey: .exams)
        
        for student in students {
            for examP in student.examParticipations {
                let exam = self.exams.first { $0.examParticipations.contains { $0.id == examP.id } }
                guard let exam else { continue }
                PersistenceController.shared.container.viewContext.delete(exam.examParticipations.first{ $0.id == examP.id }!)
                examP.exam = exam
                
                for exercise in examP.participatedExercises {
                    let examExercise = exam.exercises.first { $0.participationExercises.contains { $0.id == exercise.id } }
                    guard let examExercise else { continue }
                    PersistenceController.shared.container.viewContext.delete(examExercise.participationExercises.first { $0.id == exercise.id }!)
                    exercise.exercise = examExercise
                }
            }
        }

    }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subject, forKey: .subject)
        try container.encode(name, forKey: .name)
        try container.encode(ageGroup.rawValue, forKey: .ageGroup)
        try container.encode(weight_, forKey: .weight)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(hidden, forKey: .hidden)
        try container.encode(students, forKey: .students)
        try container.encode(exams, forKey: .exams)
    }

}
