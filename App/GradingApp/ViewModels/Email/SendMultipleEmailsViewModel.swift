//
//  SendMultipleEmailsViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation
import SwiftSMTP


protocol SendEmailProtocol: ObservableObject {
    var emailText: String { get set }
    var subject: String {get set }
    var emailKeys: [String] { get }
    var regexString: String { get }
    var recipients: [Student : Bool] { get set }
    func send(progressHandler: @escaping (_ progress: Double) -> (), completionHandler : @escaping (_ failed: [(Mail, Error)]) -> ())
}

extension SendEmailProtocol {
    func atLeastOneRecipientInActive() -> Bool {
        return recipients.contains { !$0.value }
    }
    
    func atLeastOneRecipientActive() -> Bool {
        return recipients.contains { $0.value }
    }
    
    var recipientsSorted: [Dictionary<Student, Bool>.Element] {
        return recipients.sorted(by: {$0.0.lastName < $1.0.lastName})
    }
    
    var selectedRecipients: Int {
        return recipients.filter{$0.value}.count
    }
    
    func toggleAllRecipients() {
        if !atLeastOneRecipientInActive() {
            for key in recipients.keys {
                recipients[key] = false
            }
        } else {
            for key in recipients.keys {
                recipients[key] = true
            }
        }
    }
    
    func clean(_ emailkey: String) -> String {
        var cleanedKey = emailkey
        cleanedKey.removeLast()
        cleanedKey.removeFirst()
        return cleanedKey
    }
}


class SendMultipleEmailsViewModel : SendEmailProtocol {
    let emailAccountViewModel: EmailAccountViewModel
    @Published var emailText: String = ""
    @Published var subject: String = ""
    @Published var recipients: [Student : Bool] = [:]
    
    var emailKeys: [String] {
        get { [] }
    }
    
    
    init() {
        emailAccountViewModel = EmailAccountViewModel()
    }
    
    var regexString: String {
        emailKeys.joined(separator: "|")
    }
    
    func send(progressHandler: @escaping (Double) -> (), completionHandler: @escaping ([(Mail, Error)]) -> ()) {
        preconditionFailure("Please use the overriden function")
    }
    
}
