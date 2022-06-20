//
//  AppDelegate.swift
//  GradingApp
//
//  Created by Tom Rudnick on 17.04.22.
//

import Foundation
import SwiftUI
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate {
    
    static var deviceKey: String?
    static var notificationsAllowed = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications()
        
        print("Count of Documents: \(BackupViewModel.countBackupFiles())")
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        AppDelegate.deviceKey = token
        print("Device Token: \(token)")
        let vm = BackupViewModel() 
        if vm.backupNotifyInterval != .never {
            vm.sendDeviceKeyToServer()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Method Called")
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        if aps["content-available"] as? Int == 1 {
            print("Silent Push Notification")
            BackupViewModel.doBackup()
            completionHandler(.newData)
        } else {
            print("Normal Push Notification")
            completionHandler(.noData)
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            AppDelegate.notificationsAllowed = true
            self?.getNotificationSettings()
          }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }

      }
    }
}
