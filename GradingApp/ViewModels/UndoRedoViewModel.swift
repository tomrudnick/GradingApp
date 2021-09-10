//
//  UndoRedoViewModel.swift
//  UndoRedoViewModel
//
//  Created by Tom Rudnick on 10.09.21.
//

import Foundation
import SwiftUI
import CoreData

class UndoRedoViewModel: ObservableObject {
    
    @Published var undoManagerAction: UndoManagerAction = .none
    
    enum UndoManagerAction {
        case undo
        case redo
        case none
    }
    
    func getAlert(viewContext: NSManagedObjectContext) -> Alert {
        if undoManagerAction == .undo {
            return Alert(title: Text("Achtung"),
                  message: Text("Möchten sie wirklich die letzte Veränderung Rückgängig machen?"),
                  primaryButton: .destructive(Text("Ja")) {
                    viewContext.undo()
                    viewContext.saveCustom()
                  },
                  secondaryButton: .cancel())
        } else if undoManagerAction == .redo {
            return Alert(title: Text("Achtung"),
                  message: Text("Möchten sie wirklich die letzte Änderung wiederherstellen?"),
                  primaryButton: .destructive(Text("Ja")) {
                    viewContext.redo()
                    viewContext.saveCustom()
                  },
                  secondaryButton: .cancel())
        } else {
            return Alert(title: Text("Alert"), message: Text("Alert"), dismissButton: .cancel())
        }
    }
}
