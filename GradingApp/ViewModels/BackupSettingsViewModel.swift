//
//  BackupSettingsViewModel.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 24.12.21.
//

import Foundation
import UserNotifications
import UIKit


class BackupSettingsViewModel: ObservableObject {
    
    @Published var backupTime: Date {
        didSet {
            backupTimeChanged = true
        }
    }
    @Published var backupNotifyInterval: BackupNotifyInterval = .never {
        didSet {
            backupNotifyFrequencyChanged = true
        }
    }
    var badgeViewModel: BadgeViewModel
    private(set) var notifyAllowed = false
    private(set) var backupNotifyFrequencyChanged = false
    private(set) var backupTimeChanged = false
    
    enum BackupNotifyInterval: String, CaseIterable, Identifiable {
        case test = "Test"
        case never = "Niemals"
        case daily = "Täglich"
        case weekly = "Wöchentlich"
        case biweekly = "Alle 2 Wochen"
        case monthly = "Monatlich"
        
        var id: String {
            UUID().uuidString
        }
        var name: String {
            return String(describing: self)
        }
        init?(_ describing: String) {
            for key in BackupNotifyInterval.allCases {
                if describing == key.name {
                    self = key
                    return
                }
            }
            return nil
        }
    }
    
    struct KeyValueConstants {
        static let backupTime = "backupTime"
        static let notifyFrequency = "notifyFrequency"
        static let badge = "badge"
    }
    
    let isoFormatter = ISO8601DateFormatter()
   
    
    
    init(badgeViewModel: BadgeViewModel) {
        if let backupTimeString =  NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.backupTime) {
            self.backupTime = isoFormatter.date(from: backupTimeString) ?? Date()
        } else {
            self.backupTime = Date()
        }
        if let backupNotifyIntervalString = NSUbiquitousKeyValueStore.default.string(forKey: KeyValueConstants.notifyFrequency),
           let backupNotifyIntervalEnum = BackupNotifyInterval(backupNotifyIntervalString) {
            self.backupNotifyInterval = backupNotifyIntervalEnum
        }
        isoFormatter.timeZone = TimeZone.current
        backupNotifyFrequencyChanged = false
        backupTimeChanged = false
        self.badgeViewModel = badgeViewModel
    }
    
    func save() {
        if backupTimeChanged {
            NSUbiquitousKeyValueStore.default.set(isoFormatter.string(from: backupTime), forKey: KeyValueConstants.backupTime)
            print("Update Time \(isoFormatter.string(from: backupTime))")
        }
        if backupNotifyFrequencyChanged {
            print("Update Notify Interval")
            NSUbiquitousKeyValueStore.default.set(backupNotifyInterval.name, forKey: KeyValueConstants.notifyFrequency)
        }
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func requestNotificationAuthorization() {
        #if !targetEnvironment(macCatalyst)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification zugelassen")
                self.notifyAllowed = true
            } else if let error = error {
                print("\(error.localizedDescription) Backup Einstellungsfehler")
            }
        }
        #endif
    }
    
    func addNotificationsIfNeeded() {
        #if !targetEnvironment(macCatalyst)
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notifications) in
            if !notifications.contains(where: { notification in notification.identifier == self.calcNotificationIdentifierString() }) {
                print("Local Notification is different from...")
                DispatchQueue.main.async {
                    self.addNotifications(force: true)
                }
            }
        }
        #else
        self.addNotifications(force: true)
        #endif
    }
    
    private func calcNotificationIdentifierString() -> String{
        return "backupNotification-\(backupNotifyInterval.name)-\(isoFormatter.string(from: backupTime))"
    }
    
    func addNotifications(force: Bool = false) {
        #if !targetEnvironment(macCatalyst)
            if (notifyAllowed && (backupTimeChanged || backupNotifyFrequencyChanged)) || force {
                print("ADD NOtifcations")
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.badge = 1
                center.removeAllPendingNotificationRequests()
                switch backupNotifyInterval {
                case .test:
                     let triggerTest = Calendar.current.dateComponents([.second], from: backupTime)
                     let trigger = UNCalendarNotificationTrigger(dateMatching: triggerTest, repeats: true)
                     let request = UNNotificationRequest(identifier: calcNotificationIdentifierString(), content: content, trigger: trigger)
                    center.add(request)
                case .daily:
                    let triggerDaily = Calendar.current.dateComponents([.hour,.minute], from: backupTime)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
                    let request = UNNotificationRequest(identifier: calcNotificationIdentifierString(), content: content, trigger: trigger)
                    center.add(request)
                case .weekly:
                    let triggerWeekly = Calendar.current.dateComponents([.weekday, .hour, .minute], from: backupTime)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
                    let request = UNNotificationRequest(identifier: calcNotificationIdentifierString(), content: content, trigger: trigger)
                    center.add(request)
                case .biweekly:
                    let triggerBiweekly = UNTimeIntervalNotificationTrigger(timeInterval: 1209600.0, repeats: true)
                    let request = UNNotificationRequest(identifier: calcNotificationIdentifierString(), content: content, trigger: triggerBiweekly)
                    center.add(request)
                case .monthly:
                    let triggerMonthly = Calendar.current.dateComponents([.weekdayOrdinal, .hour, .minute], from: backupTime)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: triggerMonthly, repeats: true)
                    let request = UNNotificationRequest(identifier: calcNotificationIdentifierString(), content: content, trigger: trigger)
                    center.add(request)
                case .never:
                    resetBadge()
                }
            }
        #else
            if(!backupNotifyFrequencyChanged && !force) {
                    return
            }
            switch backupNotifyInterval {
            case .never:
                resetBadge()
            default:
                return
            }
        #endif
    }
    func resetBadge() {
        print("Reset Code executed")
        badgeViewModel.badge = 0
        UIApplication.shared.applicationIconBadgeNumber = 0 //local
        NSUbiquitousKeyValueStore.default.set(0, forKey: KeyValueConstants.badge) //cloud
        NSUbiquitousKeyValueStore.default.synchronize()
    }
}
