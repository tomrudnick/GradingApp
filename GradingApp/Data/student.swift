//
//  students.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 16.07.21.
//

import Foundation

class Student: ObservableObject, Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var course: String
    
    var noten: [Note]
    
    init(id: String, firstName: String, lastName: String, email: String, course: String) {
        self.id = id
        self.firstName = firstName
        self.lastName  = lastName
        self.email = email
        self.course = course
        self.noten = []
    }
    
    func muendlichGesamt(muendlicheNoten: [Int]) -> Double {
        let sum = muendlicheNoten.reduce(0, +)
        let numberOfNoten = muendlicheNoten.count
        return Double(sum)/Double(numberOfNoten).rounded(digits: 3)
    }
}

extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
}
