//
//  SelectedHalfYearViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation
import Combine

class SelectedHalfYearViewModel : ObservableObject {
    
    @Published private(set) var activeHalf: HalfType
    @Published var canceallable: AnyCancellable?
    
    init() {
        self.activeHalf = NSUbiquitousKeyValueStore.default.longLong(forKey: MoreActionsViewModel.KeyValueConstants.selectedHalf) == 0 ? .firstHalf : .secondHalf
        
        
        canceallable = NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { _ in
                self.fetchValue()
            })
    }
    
    func fetchValue() {
        let fetchedValue: HalfType = NSUbiquitousKeyValueStore.default.longLong(forKey: MoreActionsViewModel.KeyValueConstants.selectedHalf) == 0 ? .firstHalf : .secondHalf
        if fetchedValue != activeHalf {
            activeHalf = fetchedValue
        }
    }
    
}
