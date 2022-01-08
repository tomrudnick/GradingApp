//
//  BadgeViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.01.22.
//

import Foundation
import UIKit
import Combine

class BadgeViewModel: ObservableObject {
    @Published var badge: Int
    var canceallable: AnyCancellable?
    
    init() {
        
        print("BadgeViewModel init")
        if UIApplication.shared.applicationIconBadgeNumber != UserDefaults.standard.integer(forKey: BackupSettingsViewModel.KeyValueConstants.badge) {
            badge = UIApplication.shared.applicationIconBadgeNumber
            UserDefaults.standard.set(badge, forKey: BackupSettingsViewModel.KeyValueConstants.badge)
            NSUbiquitousKeyValueStore.default.set(badge, forKey: BackupSettingsViewModel.KeyValueConstants.badge)
            NSUbiquitousKeyValueStore.default.synchronize()
        } else {
            NSUbiquitousKeyValueStore.default.synchronize()
            let onlineBadge = NSUbiquitousKeyValueStore.default.longLong(forKey: BackupSettingsViewModel.KeyValueConstants.badge)
            UIApplication.shared.applicationIconBadgeNumber = Int(onlineBadge)
            UserDefaults.standard.set(1 - onlineBadge, forKey: BackupSettingsViewModel.KeyValueConstants.badge)
            badge = Int(onlineBadge)
        }
        canceallable = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { value in
                if let dict = value.userInfo as NSDictionary? {
                    if let values = dict[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
                        if values.contains(BackupSettingsViewModel.KeyValueConstants.badge) {
                            print("received value")
                            let onlineBadge = NSUbiquitousKeyValueStore.default.longLong(forKey: BackupSettingsViewModel.KeyValueConstants.badge)
                            UIApplication.shared.applicationIconBadgeNumber = Int(onlineBadge)
                            self.badge = Int(onlineBadge)
                        }
                        if values.contains(where: { string in
                            string == BackupSettingsViewModel.KeyValueConstants.notifyFrequency ||
                            string == BackupSettingsViewModel.KeyValueConstants.backupTime
                        }) {
                            print("Update Notifications")
                            let backupSettingsViewModel = BackupSettingsViewModel(badgeViewModel: self)
                            backupSettingsViewModel.addNotifications(force: true)
                        }
                    }
                }
            })
    }
    
    func updateBadge() {
        badge = UIApplication.shared.applicationIconBadgeNumber
        if badge != UserDefaults.standard.integer(forKey: BackupSettingsViewModel.KeyValueConstants.badge) {
            print("upload")
            UserDefaults.standard.set(badge, forKey: BackupSettingsViewModel.KeyValueConstants.badge)
            NSUbiquitousKeyValueStore.default.set(badge, forKey: BackupSettingsViewModel.KeyValueConstants.badge)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
       
    }
}


