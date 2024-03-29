//
//  ExamVM.swift
//  GradingApp
//
//  Created by Tom Rudnick on 18.11.22.
//

import Foundation
import CoreData

class ExamVM: ObservableObject {
    @Published var exam: Exam?
    var context: NSManagedObjectContext!
    
    init() { }

    func setup(exam: Exam? = nil, course: Course? = nil, half: HalfType, viewContext: NSManagedObjectContext) {
        self.context = viewContext.childViewContext()
        if let exam {
            self.exam = PersistenceController.copyForEditing(of: exam, in: self.context)
        } else {
            guard let course else { fatalError("If you want to create an exam, provide a course") }
            self.exam = PersistenceController.newTemporaryInstance(in: self.context)
            self.exam?.setup(course: course, half: half)
        }
    }
    
    func persist() {
        guard let exam else { return }
        PersistenceController.persist(exam)
    }
}
