//
//  SendMultileEmailsSelectedGradeViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import SwiftSMTP

class SendMultipileEmailsSelectedGradeViewModel: SendMultipleEmailsViewModelBase {

    override var emailKeys: [String] {
        get {
            ["\\\(EmailKeys.firstName)",
             "\\\(EmailKeys.lastName)",
             "\\\(EmailKeys.oralGrade)",
             "\\\(EmailKeys.writtenGrade)",
             "\\\(EmailKeys.grade)",
             "\\\(EmailKeys.transcriptGradeHalf)",
             "\\\(EmailKeys.transcriptGrade)",
             "\\\(EmailKeys.selectedGrade)",
             "\\\(EmailKeys.selectedGradeDate)"
            ]
        }
    }
    
    func sendEmails(course: Course,
                    half: HalfType,
                    date: Date,
                    gradeStudents: [GradeStudent<Grade>],
                    progressHandler: @escaping (_ progress: Double) -> (),
                    completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
    {
        let multipleEmailSender = SendMultipleEmails(emailViewModel: emailViewModel)
        multipleEmailSender.sendEmails(subject: subject, emailText: emailText, course: course, half: half, emailTextReplaceHandler: { emailText, student in
            var emailString = SendMultipleEmails.standardReplacementEmailString(emailText, student: student, half: half)
            
            emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGradeDate, with: date.asString(format: "dd.MM.yyyy"))
            emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGrade, with: gradeStudents.first(where: { gradeStudent in
                gradeStudent.student == student
            })!.grade!.toString())
        
            return emailString
        }, progressHandler: progressHandler, completionHandler: completionHandler)
    }
}
