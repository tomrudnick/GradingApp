//
//  MultipleEmails.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import KeychainAccess
import SwiftSMTP

class SendMultipleEmails {
    private let emailAccountViewModel: EmailAccountViewModel
    init(emailAccountViewModel: EmailAccountViewModel) {
        self.emailAccountViewModel = emailAccountViewModel
    }
    
    var smtp: SMTP {
        SMTP(hostname: emailAccountViewModel.hostname,
             email: emailAccountViewModel.username,
             password: emailAccountViewModel.password,
             port: Int32(emailAccountViewModel.portInt),
             tlsMode: .requireTLS,
             tlsConfiguration: nil,
             authMethods: [],
             domainName: "localhost",
             timeout: 10)
    }
    
    func sendEmails(subject: String,
                    emailText: String,
                    students: [Student],
                    emailTextReplaceHandler: (_ emailText: String, _ student: Student) -> (String),
                    progressHandler: @escaping (_ progress: Double) -> (),
                    completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ()) {
        var mails: [Mail] = []
        let sender = Mail.User(email: emailAccountViewModel.email)
        for student in students {
            let receiverStudent = Mail.User(name: "\(student.firstName) \(student.lastName)", email: student.email)
            let emailString = emailTextReplaceHandler(emailText, student)
            mails.append(Mail(from: sender,
                               to: [receiverStudent],
                               subject: subject,
                               text: emailString
                         )
            )
        }
        _sendEmails(smtp: smtp, mails: mails, progressHandler: progressHandler, completionHandler: completionHandler)
    }
    
    
    func sendEmailsWithAttachments(subject: String,
                                   emailText: String,
                                   students: [Student : [Attachment]],
                                   emailTextReplaceHandler: (_ emailText: String, _ student: Student) -> (String),
                                   progressHandler: @escaping (_ progress: Double) -> (),
                                   completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ()) {
        var mails: [Mail] = []
        let sender = Mail.User(email: emailAccountViewModel.email)
        for (student, attachments) in students {
            let receiverStudent = Mail.User(name: "\(student.firstName) \(student.lastName)", email: student.email)
            let emailString = emailTextReplaceHandler(emailText, student)
            mails.append(Mail(from: sender,
                               to: [receiverStudent],
                               subject: subject,
                               text: emailString,
                               attachments: attachments
                         )
            )
            _sendEmails(smtp: smtp, mails: mails, progressHandler: progressHandler, completionHandler: completionHandler)
        }
    }
    
    private func _sendEmails(smtp: SMTP, mails: [Mail], progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ()) {
        smtp.send(mails,
            progress: { (mail, error) in
                let index = mails.firstIndex(where: {mail.id == $0.id}) ?? 0
                let progress = Double(index) / Double(mails.count)
                progressHandler(progress)
            },
            completion: { (sent, failed) in
                completionHandler(failed)
                for fail in failed {
                    print(fail.1)
                }
            }
        )
    }
    
    static func standardReplacementEmailString(_ text: String, student: Student, half: HalfType) -> String {
        var emailString = text.replacingOccurrences(of: EmailKeys.firstName, with: student.firstName)
        emailString = emailString.replacingOccurrences(of: EmailKeys.lastName, with: student.lastName)
        emailString = emailString.replacingOccurrences(of: EmailKeys.oralGrade, with: student.getRoundedGradeAverage(.oral, half: half))
        emailString = emailString.replacingOccurrences(of: EmailKeys.writtenGrade, with: student.getRoundedGradeAverage(.written, half: half))
        emailString = emailString.replacingOccurrences(of: EmailKeys.transcriptGradeHalf, with: student.transcriptGrade?.getTranscriptGradeHalfValueString(half: half) ?? "-")
        emailString = emailString.replacingOccurrences(of: EmailKeys.transcriptGrade, with: student.transcriptGrade?.getTranscriptGradeValueString() ?? "-")
        emailString = emailString.replacingOccurrences(of: EmailKeys.grade, with: student.getRoundedGradeAverage(half: half))
        return emailString
    }
}
