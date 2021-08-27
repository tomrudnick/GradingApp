//
//  SelectedHalfYearViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation

class SelectedHalfYearViewModel : ObservableObject {
    
    @Published private(set) var activeHalf: HalfType
    
    init() {
        self.activeHalf = NSUbiquitousKeyValueStore.default.longLong(forKey: KeyValueConstants.selectedHalf) == 0 ? .firstHalf : .secondHalf
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    func fetchValue() {
        let fetchedValue: HalfType = NSUbiquitousKeyValueStore.default.longLong(forKey: KeyValueConstants.selectedHalf) == 0 ? .firstHalf : .secondHalf
        if fetchedValue != activeHalf {
            activeHalf = fetchedValue
        }
    }
    
    @objc func onUbiquitousKeyValueStoreDidChangeExternally(notification:Notification)
    {
        fetchValue()
    }
}
