//
//  SendMultipleEmailsViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import SwiftSMTP

class SendMultipleEmailsViewModel : SendMultipleEmailsViewModelBase {
    
    
    override var emailKeys: [String] {
        get {
            ["\\\(EmailKeys.firstName)",
             "\\\(EmailKeys.lastName)",
             "\\\(EmailKeys.oralGrade)",
             "\\\(EmailKeys.writtenGrade)",
             "\\\(EmailKeys.grade)",
             "\\\(EmailKeys.transcriptGradeHalf)",
             "\\\(EmailKeys.transcriptGrade)"
            ]
        }
    }
    
    func sendEmails(course: Course,
                    half: HalfType,
                    progressHandler: @escaping (_ progress: Double) -> (),
                    completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
    {
        let multipleEmailSender = SendMultipleEmails(emailViewModel: emailViewModel)
        multipleEmailSender.sendEmails(subject: subject, emailText: emailText, course: course, half: half, emailTextReplaceHandler: { emailText, student in
            return SendMultipleEmails.standardReplacementEmailString(emailText, student: student, half: half)
        }, progressHandler: progressHandler, completionHandler: completionHandler)
    }
}
