//
//  SendSingleEmailViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import SwiftSMTP


class SendSingleEmailViewModel: SendEmailProtocol {
    let emailViewModel: EmailViewModel
    
    @Published var emailText: String = ""
    @Published var subject: String = ""
    
    //we assume O(1) beacuse gradeNumber should in practice be very small (< 10)
    var emailKeys: [String] {
        get {
            var keys = ["\\\(EmailKeys.firstName)",
             "\\\(EmailKeys.lastName)",
             "\\\(EmailKeys.oralGrade)",
             "\\\(EmailKeys.grade)",
             "\\\(EmailKeys.transcriptGradeHalf)",
             "\\\(EmailKeys.transcriptGrade)"
            ]
            for i in 0..<gradeNumber {
                keys.append("\\$writtenGrade_\(i + 1)")
            }
            keys.append("\\\(EmailKeys.writtenGrade)")
            return keys
        }
    }
    
    var regexString: String {
        emailKeys.joined(separator: "|")
    }
    
    var student: Student?
    var half: HalfType?
    
    private var gradeNumber: Int
    private var writtenGrades: [Grade]
    
    init() {
        self.emailViewModel = EmailViewModel()
        gradeNumber = 0
        self.writtenGrades = []
    }
    
    func fetchData(student: Student, half: HalfType) {
        self.student = student
        self.half = half
        self.writtenGrades = student.gradesArr.filter({$0.type == .written && $0.half == half}).sorted(by: {$0.date! < $1.date! })
        self.gradeNumber = writtenGrades.count
    }

    
    func send(progressHandler: @escaping (Double) -> (), completionHandler: @escaping ([(Mail, Error)]) -> ()) {
        if let student = student, let half = half {
            let emailSender = SendMultipleEmails(emailViewModel: emailViewModel)
            emailSender.sendEmails(subject: subject, emailText: emailText, students: [student], half: half, emailTextReplaceHandler: { emailText, student in
                var emailString = emailText
                for i in 0..<gradeNumber {
                    let target = "$writtenGrade_\(i + 1)"
                    emailString = emailString.replacingOccurrences(of:target, with: self.writtenGrades[i].toString())
                    
                }
               return SendMultipleEmails.standardReplacementEmailString(emailString, student: student, half: half)
            }, progressHandler: progressHandler, completionHandler: completionHandler)
        }
    }
}