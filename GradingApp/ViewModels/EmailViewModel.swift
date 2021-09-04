//
//  EmailViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import Foundation
import KeychainAccess
import SwiftSMTP

class EmailViewModel: ObservableObject {
    
    struct KeyValueConstants {
        static let emailActive = "emailActive"
        static let email = "email"
        static let hostname = "hostname"
        static let port = "port"
        static let password = "password"
    }
    
    struct EmailKeys {
        static let firstName = "$firstName"
        static let lastName = "$lastName"
        static let oralGrade = "$oralGrade"
        static let writtenGrade = "$writtenGrade"
        static let grade = "$grade"
        static let transcriptGradeHalf = "$transcriptGradeHalf"
        static let transcriptGrade = "$transcriptGrade"
    }
    
    @Published var email: String
    @Published var hostname: String
    @Published var port: String
    @Published var emailAccountUsed: Bool
    @Published var password: String
    
    var portInt: Int {
        get {
            Int(port) ?? 0
        }
        set {
            port = String(newValue)
        }
    }
    
    let keychain: Keychain
    
    init() {
        let keychain = Keychain(service: "com.rudnick.gradingapp").synchronizable(true)
        self.keychain = keychain
        self.emailAccountUsed = NSUbiquitousKeyValueStore.default.bool(forKey: KeyValueConstants.emailActive)
        self.email = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.email) ?? ""
        self.hostname = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.hostname) ?? ""
        self.port = String(NSUbiquitousKeyValueStore.default.longLong(forKey: KeyValueConstants.port))
        self.password = keychain[KeyValueConstants.password] ?? ""
    }
    
    func save() {
        print(port)
        keychain[KeyValueConstants.password] = self.password
        NSUbiquitousKeyValueStore.default.set(email, forKey: KeyValueConstants.email)
        NSUbiquitousKeyValueStore.default.set(hostname, forKey: KeyValueConstants.hostname)
        NSUbiquitousKeyValueStore.default.set(port, forKey: KeyValueConstants.port)
        NSUbiquitousKeyValueStore.default.set(emailAccountUsed, forKey: KeyValueConstants.emailActive)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func sendEmails(emailText: String, course: Course, half: HalfType, progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ()) {
        let smtp = SMTP(hostname: hostname, email: self.email, password: password, port: Int32(portInt), tlsMode: .requireTLS, tlsConfiguration: nil, authMethods: [], domainName: "localhost", timeout: 10)
        var mails: [Mail] = []
        let sender = Mail.User(email: self.email)
        for student in course.studentsArr {
            let receiverStudent = Mail.User(email: student.email)
            var emailString = emailText.replacingOccurrences(of: EmailKeys.firstName, with: student.firstName)
            emailString = emailString.replacingOccurrences(of: EmailKeys.lastName, with: student.lastName)
            emailString = emailString.replacingOccurrences(of: EmailKeys.oralGrade, with: student.getSimpleGradeAverage(.oral, half: half))
            emailString = emailString.replacingOccurrences(of: EmailKeys.writtenGrade, with: student.getSimpleGradeAverage(.written, half: half))
            emailString = emailString.replacingOccurrences(of: EmailKeys.transcriptGradeHalf, with: student.transcriptGrade?.getTranscriptGradeHalfValueString(half: half) ?? "-")
            emailString = emailString.replacingOccurrences(of: EmailKeys.transcriptGrade, with: student.transcriptGrade?.getCalculatedValueString() ?? "-")
            emailString = emailString.replacingOccurrences(of: EmailKeys.grade, with: student.getSimpleGradeAverage(half: half))
            mails.append(Mail(from: sender,
                               to: [receiverStudent],
                               subject: "Note",
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
            }
        )
    }
    
}
