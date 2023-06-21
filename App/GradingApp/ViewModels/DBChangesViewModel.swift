//
//  DBChangesViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 21.06.23.
//

import SwiftUI
import Combine
import CoreData

//This ViewModel allows you to track if a specific ViewContext has unsaved Changes
class DBChangesViewModel: ObservableObject {
    @Published var hasChanges: Bool = false
    var viewContext: NSManagedObjectContext? = nil
    private var cancellable: AnyCancellable? = nil

    //Since we will setup this Class in the onAppear Method there is nothing to do
    init() {
        
    }
    
    //Pass the viewContext in order to track changes in the hasChanges variable.
    //Call it in the onAppear Method
    //You can only observe one ViewContext (the last one you passed to this function)
    func setup(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        cancellable = viewContext.publisher(for: \.hasChanges)
            .receive(on: DispatchQueue.main)
            .sink { hasChanges in
                self.hasChanges = hasChanges
            }
    }
    
    //In case you don't want to track any changes anymore, use this method.
    func unsubscribe() {
        self.viewContext = nil
        self.cancellable = nil
    }
    
}
