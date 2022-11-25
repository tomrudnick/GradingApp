//
//  Student+CoreDataClass.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 05.09.21.
//
//

import Foundation
import CoreData

@objc(Student)
public class Student: NSManagedObject, Codable, StudentName {
    
    private enum CodingKeys: String, CodingKey { case  firstName, lastName, email, hidden, grades, transcriptGrade, examParticipations}
    
   
    
    required public convenience init(from decoder: Decoder) throws {
        self.init(context: PersistenceController.shared.container.viewContext)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try! container.decode(String.self, forKey: .firstName)
        lastName = try! container.decode(String.self, forKey: .lastName)
        email = try! container.decode(String.self, forKey: .email)
        hidden = try! container.decode(Bool.self, forKey: .hidden)
        grades = try! container.decode(Set<Grade>.self, forKey: .grades)
        let transcriptGradeWrapper = try? container.decode(TranscriptGradeDecodeWrapper.self, forKey: .transcriptGrade)
        self.transcriptGrade = transcriptGradeWrapper?.transcriptGrade
        self.examParticipations = try! container.decode(Set<ExamParticipation>.self, forKey: .examParticipations)
        

    }

    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(hidden, forKey: .hidden)
        try container.encode(grades, forKey: .grades)
        if let transcriptGrade = transcriptGrade {
            try container.encode(TranscriptGradeDecodeWrapper(transcriptGrade: transcriptGrade),forKey: .transcriptGrade)
        }
        try container.encode(examParticipations, forKey: .examParticipations)
    }

}

protocol StudentName {
    var firstName: String {get}
    var lastName: String {get}
}
