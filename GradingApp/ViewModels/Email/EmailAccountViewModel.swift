//
//  EmailViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import Foundation
import KeychainAccess
import SwiftSMTP



class EmailAccountViewModel: ObservableObject {
    
    struct KeyValueConstants {
        static let emailActive = "emailActive"
        static let email = "email"
        static let username = "username"
        static let hostname = "hostname"
        static let port = "port"
        static let password = "password"
    }

    
    @Published var email: String
    @Published var hostname: String
    @Published var port: String
    @Published var emailAccountUsed: Bool
    @Published var password: String
    @Published var username: String
    
    var portInt: Int {
        get {
            Int(port) ?? 0
        }
        set {
            port = String(newValue)
        }
    }
    
    private let keychain: Keychain
    
    init() {
        let keychain = Keychain(service: "com.rudnick.gradingapp").synchronizable(true)
        self.keychain = keychain
        self.emailAccountUsed = NSUbiquitousKeyValueStore.default.bool(forKey: KeyValueConstants.emailActive)
        self.email = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.email) ?? ""
        self.username = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.username) ?? ""
        self.hostname = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.hostname) ?? ""
        self.port = String(NSUbiquitousKeyValueStore.default.longLong(forKey: KeyValueConstants.port))
        self.password = keychain[KeyValueConstants.password] ?? ""
    }
    
    func save() {
        keychain[KeyValueConstants.password] = self.password
        NSUbiquitousKeyValueStore.default.set(email, forKey: KeyValueConstants.email)
        NSUbiquitousKeyValueStore.default.set(username, forKey: KeyValueConstants.username)
        NSUbiquitousKeyValueStore.default.set(hostname, forKey: KeyValueConstants.hostname)
        NSUbiquitousKeyValueStore.default.set(port, forKey: KeyValueConstants.port)
        NSUbiquitousKeyValueStore.default.set(emailAccountUsed, forKey: KeyValueConstants.emailActive)
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
