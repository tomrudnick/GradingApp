//
//  SendMultileEmailsSelectedGradeViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import SwiftSMTP

class SendMultipileEmailsSelectedGradeViewModel: SendMultipleEmailsViewModelBase {

    private var half: HalfType?
    private var date: Date?
    private var gradeStudents: [GradeStudent<Grade>]?
    
    override var emailKeys: [String] {
        get {
            ["\\\(EmailKeys.firstName)",
             "\\\(EmailKeys.lastName)",
             "\\\(EmailKeys.selectedGradeDate)",
             "\\\(EmailKeys.selectedGrade)",
             "\\\(EmailKeys.oralGrade)",
             "\\\(EmailKeys.writtenGrade)",
             "\\\(EmailKeys.grade)",
             "\\\(EmailKeys.transcriptGradeHalf)",
             "\\\(EmailKeys.transcriptGrade)"
            ]
        }
    }
    
    func fetchData(half: HalfType, date: Date, gradeStudents: [GradeStudent<Grade>]) {
        self.date = date
        self.gradeStudents = gradeStudents
        self.half = half
    }
    
    override func send(progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
    {
        if let half = half, let date = date, let gradeStudents = gradeStudents {
            let students = gradeStudents.filter({$0.grade != nil}).map({$0.student})
            let multipleEmailSender = SendMultipleEmails(emailViewModel: emailViewModel)
            multipleEmailSender.sendEmails(subject: subject, emailText: emailText, students: students, half: half, emailTextReplaceHandler: { emailText, student in
                var emailString = SendMultipleEmails.standardReplacementEmailString(emailText, student: student, half: half)
                
                emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGradeDate, with: date.asString(format: "dd.MM.yyyy"))
                emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGrade, with: gradeStudents.first(where: { gradeStudent in
                    gradeStudent.student == student
                })!.grade!.toString())
            
                return emailString
            }, progressHandler: progressHandler, completionHandler: completionHandler)
        }
    }
}
