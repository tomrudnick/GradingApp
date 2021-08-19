//
//  Course+StudentHelper.swift
//  GradingApp
//
//  Created by Tom Rudnick on 19.08.21.
//

import Foundation


extension Course {
    func nextStudent(after student: Student) -> Student?{
        guard let currentStudentIndex = self.studentsArr.firstIndex(where: {$0 == student}) else {
            return nil
        }
        if currentStudentIndex < self.studentsArr.count - 1{
            return self.studentsArr[currentStudentIndex + 1]
        } else {
            return nil
        }
    }
    
    func previousStudent(before student: Student) -> Student? {
        guard let currentStudentIndex = self.studentsArr.firstIndex(where: {$0 == student}) else {
            return nil
        }
        if currentStudentIndex > 0 {
            return self.studentsArr[currentStudentIndex - 1]
        } else {
            return nil
        }
    }
}
