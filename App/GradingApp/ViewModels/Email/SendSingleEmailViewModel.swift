//
//  SendSingleEmailViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import SwiftSMTP


class SendSingleEmailViewModel: SendEmailProtocol {
    let emailAccountViewModel: EmailAccountViewModel
    
    @Published var emailText: String = ""
    @Published var subject: String = ""
    @Published var recipients: [Student : Bool] = [:]
    
    //we assume O(1) beacuse gradeNumber should in practice be very small (< 10)
    var emailKeys: [String] {
        get {
            var keys = ["\(EmailKeys.firstName)",
             "\(EmailKeys.lastName)",
             "\(EmailKeys.oralGrade)",
             "\(EmailKeys.grade)",
             "\(EmailKeys.transcriptGradeHalf)",
             "\(EmailKeys.transcriptGrade)"
            ]
            for i in 0..<gradeNumber {
                keys.append("schriftliche Note \(i + 1)")
            }
            keys.append("\(EmailKeys.writtenGrade)")
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
        self.emailAccountViewModel = EmailAccountViewModel()
        gradeNumber = 0
        self.writtenGrades = []
    }
    
    func fetchData(student: Student, half: HalfType) {
        self.student = student
        self.half = half
        self.writtenGrades = student.gradesArr.filter({$0.type == .written && $0.half == half}).sorted(by: {$0.date! < $1.date! })
        self.gradeNumber = writtenGrades.count
        self.recipients [student] = true
    }

    
    func send(progressHandler: @escaping (Double) -> (), completionHandler: @escaping ([(Mail, Error)]) -> ()) {
        if let student = student, let half = half {
            let emailSender = SendMultipleEmails(emailAccountViewModel: emailAccountViewModel)
            emailSender.sendEmails(subject: subject, emailText: emailText, students: [student], emailTextReplaceHandler: { emailText, student in
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
