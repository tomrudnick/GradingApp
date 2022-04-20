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
