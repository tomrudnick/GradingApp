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
    }
    
    let isoFormatter = ISO8601DateFormatter()
   
    
    
    init() {
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
        if backupTimeChanged || backupNotifyFrequencyChanged {
            sendRequestToServer()
        }
        
    }
    
    private func sendRequestToServer() {
        guard let deviceKey = AppDelegate.deviceKey else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: backupTime)
        var json: [String: Any] = [:]
        
        if backupNotifyInterval == .never {
            json = ["device_key" : deviceKey,
                    "remove" : "true"]
        } else {
            json = ["device_key" : deviceKey,
                   "time" : dateString,
                   "frequency" : backupNotifyInterval.name]
        }
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://tomrudnick.de:8080")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        task.resume()
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
    
    static func doBackup() {
        if let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            if !FileManager.default.fileExists(atPath: containerUrl.path, isDirectory: nil) {
                do {
                    try FileManager.default.createDirectory(at: containerUrl, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd_MM_YYYY"
            let date = dateFormatter.string(from: Date())
            print("Filename: \(date)")
            let fileUrl = containerUrl.appendingPathComponent(date)
            do {
                let fetchedCourses = PersistenceController.fetchData(context: PersistenceController.shared.container.viewContext, fetchRequest: Course.fetchAll())
                let jsonData = try JSONEncoder().encode(fetchedCourses)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                try jsonString.write(to: fileUrl, atomically: true, encoding: .utf8)
            } catch {
                print("Error fetching data from CoreData", error)
            }
        }
    }
    //returns -1 if an Error occured
    static func countBackupFiles() -> Int{
        if let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            
            let dirContents = try? FileManager.default.contentsOfDirectory(at: containerUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let count = dirContents?.count
            return count ?? -1
        }
        return -1
    }
    
    static func getBackupFiles() -> [URL] {
        if let containerUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            
            let dirContents = try? FileManager.default.contentsOfDirectory(at: containerUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return dirContents ?? []
        }
        return []
    }
}
