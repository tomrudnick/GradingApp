//
//  Course+DataModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 17.08.21.
//

import Foundation


extension Student {
    struct DataModel : Identifiable, StudentName {
        var id: UUID
        var firstName: String
        var lastName: String
        var email: String
        var deleted: Bool
        var hidden: Bool
        
        init(id: UUID = UUID(), firstName: String, lastName: String, email: String, deleted: Bool = false, hidden: Bool) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.email = email
            self.deleted = deleted
            self.hidden = hidden
        }
        
        mutating func update(for student: DataModel) {
            self.firstName = student.firstName
            self.lastName = student.lastName
            self.email = student.email
            self.hidden = student.hidden
            self.deleted = student.deleted
        }
        
        mutating func toggleDelete() {
            self.deleted.toggle()
        }
    
    }
    
    func update(for student: DataModel) {
        self.firstName = student.firstName
        self.lastName = student.lastName
        self.email = student.email
        self.hidden = student.hidden
    }
}
