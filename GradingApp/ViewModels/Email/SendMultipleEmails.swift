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
    private let emailViewModel: EmailViewModel
    init(emailViewModel: EmailViewModel) {
        self.emailViewModel = emailViewModel
    }
    
    func sendEmails(subject: String, emailText: String, students: [Student], emailTextReplaceHandler: (_ emailText: String, _ student: Student) -> (String) , progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ()) {
        let smtp = SMTP(hostname: emailViewModel.hostname, email: emailViewModel.username, password: emailViewModel.password, port: Int32(emailViewModel.portInt), tlsMode: .requireTLS, tlsConfiguration: nil, authMethods: [], domainName: "localhost", timeout: 10)
        var mails: [Mail] = []
        let sender = Mail.User(email: emailViewModel.email)
        for student in students {
            let receiverStudent = Mail.User(name: "\(student.firstName) \(student.lastName)", email: student.email)
            let emailString = emailTextReplaceHandler(emailText, student)
            print(emailString) //Debug
            mails.append(Mail(from: sender,
                               to: [receiverStudent],
                               subject: subject,
                               text: emailString
                         )
            )
        }
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
