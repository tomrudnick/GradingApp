//
//  SendMultipleEmailsExamAttachmentViewModel.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 25.12.22.
//

import Foundation
import SwiftSMTP

class SendMultipleEmailsExamAttachmentViewModel: SendMultipleEmailsViewModel {

    private var half: HalfType?
    private(set) var exam: Exam?
    private var attachments: [Student : PDFFile] = [:]
    
    override var emailKeys: [String] {
        get {
            ["\\\(EmailKeys.firstName)",
             "\\\(EmailKeys.lastName)",
             "\\\(EmailKeys.selectedGradeDate)",
             "\\\(EmailKeys.selectedGrade)",
             "\\\(EmailKeys.points)",
             "\\\(EmailKeys.maxpoints)",
             "\\\(EmailKeys.oralGrade)",
             "\\\(EmailKeys.writtenGrade)",
             "\\\(EmailKeys.grade)",
             "\\\(EmailKeys.transcriptGradeHalf)",
             "\\\(EmailKeys.transcriptGrade)"
            ]
        }
    }
    
    func fetchData(half: HalfType, exam: Exam) {
        self.exam = exam
        self.half = half
        self.recipients = Dictionary(uniqueKeysWithValues: exam.examParticipations.filter(\.participated).compactMap(\.student).map { ($0, true) })
    }
    
    func fetchAttachments(_ attachments: [Student: PDFFile]) {
        self.attachments = attachments
    }
    
    override func send(progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
    {
        guard let half else { return }
        
        let multipleEmailSender = SendMultipleEmails(emailAccountViewModel: emailAccountViewModel)
        multipleEmailSender.sendEmailsWithAttachments(subject: subject,
                                                      emailText: emailText,
                                                      students: generateAttachments(),
         emailTextReplaceHandler: { emailText, student in
            var emailString = SendMultipleEmails.standardReplacementEmailString(emailText, student: student, half: half)
            replaceHandler(emailString: &emailString, student: student)
            return emailString
        }, progressHandler: progressHandler, completionHandler: completionHandler)
    }
    
    private func replaceHandler(emailString: inout String, student: Student) {
        guard let exam else { return }
        emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGradeDate, with: exam.date.asString(format: "dd.MM.yyyy"))
        emailString = emailString.replacingOccurrences(of: EmailKeys.selectedGrade, with: String(exam.getGrade(for: student)))
        emailString = emailString.replacingOccurrences(of: EmailKeys.points, with: String(format: "%.2f", exam.getTotalPoints(for: student)))
        emailString = emailString.replacingOccurrences(of: EmailKeys.maxpoints, with: String(format: "%.2f", exam.getMaxPointsPossible()))
    }
    
    private func generateAttachments() -> [Student: [Attachment]] {
        Dictionary(uniqueKeysWithValues: self.attachments
            .filter{ self.recipients[$0.key] ?? false }
            .map { student, file in
                let attachment = Attachment(data: file.data, mime: "application/pdf", name: file.fileName)
                return (student, [attachment])
            }
        )
    }
}
