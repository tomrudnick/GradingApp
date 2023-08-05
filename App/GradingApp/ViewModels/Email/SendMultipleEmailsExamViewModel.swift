//
//  SendMultipleEmailsExamViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.11.22.
//

import Foundation
import SwiftSMTP

class SendMultipleEmailsExamViewModel: SendMultipleEmailsViewModel {

    private var half: HalfType?
    private var exam: Exam?
    
    override var emailKeys: [String] {
        get {
            ["\(EmailKeys.firstName)",
             "\(EmailKeys.lastName)",
             "\(EmailKeys.selectedGradeDate)",
             "\(EmailKeys.selectedGrade)",
             "\(EmailKeys.points)",
             "\(EmailKeys.maxpoints)",
             "\(EmailKeys.oralGrade)",
             "\(EmailKeys.writtenGrade)",
             "\(EmailKeys.grade)",
             "\(EmailKeys.transcriptGradeHalf)",
             "\(EmailKeys.transcriptGrade)"
            ]
        }
    }
    
    func fetchData(half: HalfType, exam: Exam) {
        self.exam = exam
        self.half = half
        self.recipients = Dictionary(uniqueKeysWithValues: exam.examParticipations.filter(\.participated).compactMap(\.student).map { ($0, true) })
    }
    
    override func send(progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
    {
        if let half, let exam {
            let students = recipients.filter({$0.1}).map({$0.0})
            let multipleEmailSender = SendMultipleEmails(emailAccountViewModel: emailAccountViewModel)
            multipleEmailSender.sendEmails(subject: subject, emailText: emailText, students: students, emailTextReplaceHandler: { emailText, student in
                var emailString = SendMultipleEmails.standardReplacementEmailString(emailText, student: student, half: half)
                
                emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGradeDate, with: exam.date.asString(format: "dd.MM.yyyy"))
                emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGrade, with: String(exam.getGrade(for: student)))
                emailString = emailString.replacingOccurrences(of: EmailKeys.points, with: String(format: "%.2f", exam.getTotalPoints(for: student)))
                emailString = emailString.replacingOccurrences(of: EmailKeys.maxpoints, with: String(format: "%.2f", exam.getMaxPointsPossible()))
            
                return emailString
            }, progressHandler: progressHandler, completionHandler: completionHandler)
        }
    }
}
