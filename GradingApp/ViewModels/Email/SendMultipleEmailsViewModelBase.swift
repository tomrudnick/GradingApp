//
//  SendMultipleEmailsViewModelBase.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation


protocol SendEmailProtocol: ObservableObject {
    var emailText: String { get set }
    var subject: String {get set }
    var emailKeys: [String] { get }
    var regexString: String { get }
}


class SendMultipleEmailsViewModelBase : SendEmailProtocol {
    let emailViewModel: EmailViewModel
    @Published var emailText: String = ""
    @Published var subject: String = ""
    
    var emailKeys: [String] {
        get { [] }
    }
    
    init() {
        emailViewModel = EmailViewModel()
    }
    
    var regexString: String {
        emailKeys.joined(separator: "|")
    }

}
