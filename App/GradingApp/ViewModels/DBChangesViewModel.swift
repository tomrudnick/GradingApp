//
//  DBChangesViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 21.06.23.
//

import SwiftUI
import Combine

//This ViewModel allows you to track if a specific ViewContext has Changes

class DBChangesViewModel: ObservableObject {
    @Published var hasChanges: Bool = false
    var viewContext: NSManagedObjectContext? = nil
    private var cancellable: AnyCancellable? = nil

    init() {
        
    }
    
    //Pass the viewContext in order to track changes in the hasChanges variable.
    //Call it in the onAppear Method
    func setup(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        cancellable = viewContext.publisher(for: \.hasChanges)
            .receive(on: DispatchQueue.main)
            .sink { hasChanges in
                self.hasChanges = hasChanges
            }
    }
    
    func unsubscribe() {
        self.viewContext = nil
        self.cancellable = nil
    }
    
}
