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
    
    func fetchData(course: Course, half: HalfType) {
        self.course = course
        self.half = half
        self.recipients = Dictionary(uniqueKeysWithValues: course.students.map({ student in
            (student, true)
        }))
    }
    
    override func send(progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
    {
        if let course = course, let half = half {
            let multipleEmailSender = SendMultipleEmails(emailAccountViewModel: emailAccountViewModel)
            multipleEmailSender.sendEmails(subject: subject,
                                           emailText: emailText,
                                           students: course.studentsArr,
                                           emailTextReplaceHandler: { emailText, student in
                                                return SendMultipleEmails.standardReplacementEmailString(emailText, student: student, half: half)
                                           }, progressHandler: progressHandler, completionHandler: completionHandler
            )
        }
        
    }
}
