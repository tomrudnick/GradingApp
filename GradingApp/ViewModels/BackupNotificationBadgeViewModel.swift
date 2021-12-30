//
//  BackupNotificationBadgeViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 30.12.21.
//

import Foundation
import UIKit
import Combine

class BackupNotificationBadgeViewModel : ObservableObject {
    
    @Published var canceallable: AnyCancellable?
    
    init() {
        canceallable = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { value in
                print("Belastend:")
                if let dict = value.userInfo as NSDictionary? {
                    if let values = dict[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] {
                        if values.contains(BackupSettingsViewModel.KeyValueConstants.badge) {
                            if NSUbiquitousKeyValueStore.default.longLong(forKey: BackupSettingsViewModel.KeyValueConstants.badge) == 0 {
                                UIApplication.shared.applicationIconBadgeNumber = 0
                                print("Resetted badge")
                                NSUbiquitousKeyValueStore.default.set(1, forKey: BackupSettingsViewModel.KeyValueConstants.badge)
                                NSUbiquitousKeyValueStore.default.synchronize()
                            }
                        }
                        
                        if values.contains(where: { string in
                            string == BackupSettingsViewModel.KeyValueConstants.notifyFrequency ||
                            string == BackupSettingsViewModel.KeyValueConstants.backupTime
                        }) {
                            print("updated notifications")
                            let backupSettingsViewModel = BackupSettingsViewModel()
                            backupSettingsViewModel.addNotifications(force: true)
                        }
                    }
                }
            })
    }
    
    func updateOnlineBadge() {
        if UIApplication.shared.applicationIconBadgeNumber == 1 {
            NSUbiquitousKeyValueStore.default.set(1, forKey: BackupSettingsViewModel.KeyValueConstants.badge)
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        
    }
}
