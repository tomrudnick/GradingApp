//
//  SendMultipleEmailsCourseViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import SwiftSMTP

class SendMultipleEmailsCourseViewModel : SendMultipleEmailsViewModel {
    
    private var course: Course?
    private var half: HalfType?
    
    override var emailKeys: [String] {
        get {
            if half == HalfType.firstHalf {
                return ["\\\(EmailKeys.firstName)",
                 "\\\(EmailKeys.lastName)",
                 "\\\(EmailKeys.oralGrade)",
                 "\\\(EmailKeys.writtenGrade)",
                 "\\\(EmailKeys.grade)",
                 "\\\(EmailKeys.transcriptGradeHalf)",
                 "\\\(EmailKeys.transcriptGrade)"
                ]
            }
            else {
                return ["\\\(EmailKeys.firstName)",
                 "\\\(EmailKeys.lastName)",
                 "\\\(EmailKeys.oralGrade)",
                 "\\\(EmailKeys.writtenGrade)",
                 "\\\(EmailKeys.grade)",
                 "\\\(EmailKeys.transcriptGradeHalf)",
                 "\\\(EmailKeys.transcriptGradeFirstHalf)",
                 "\\\(EmailKeys.transcriptGrade)"
                ]
            }
        }
    }
    
    func fetchData(course: Course, half: HalfType) {
        self.course = course
        self.half = half
        self.recipients = Dictionary(uniqueKeysWithValues: course.students.filter({!$0.hidden}).map({($0, true)}))
    }
    
    override func send(progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
    {
        if let half = half {
            let multipleEmailSender = SendMultipleEmails(emailAccountViewModel: emailAccountViewModel)
            multipleEmailSender.sendEmails(subject: subject,
                                           emailText: emailText,
                                           students: recipients.filter({$0.1}).map({$0.0}),
                                           emailTextReplaceHandler: { emailText, student in
                                                return SendMultipleEmails.standardReplacementEmailString(emailText, student: student, half: half)
                                           }, progressHandler: progressHandler, completionHandler: completionHandler
            )
        }
        
    }
}
