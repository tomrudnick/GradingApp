//
//  EditSingleGradeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//

import SwiftUI

struct EditSingleGradeView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var student: Student
    @ObservedObject var grade: Grade
    
    var body: some View {
        
        SingleGradeView(student: student, gradeDate: grade.date!, selectedGradeType: grade.type, currentGrade: grade.value, gradeMultiplier: grade.multiplier, comment: grade.comment!, showSaveCancelButtons: false) { points, type, multiplier, date, comment in
            self.grade.value = Int32(points)
            self.grade.type = type
            self.grade.multiplier = multiplier
            self.grade.date = date
            self.grade.comment = comment
            do {
                try viewContext.save()
                self.student.objectWillChange.send()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

//----------------------------Preview-------------------------------

struct EditSingleGradeView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        
        let student = (previewData(context: PersistenceController.preview.container.viewContext).first(where: {$0.name == "Mathe 10FLS"})?.studentsArr.first!)!
        
        let grade = student.gradesArr.first!
        
        EditSingleGradeView(student: student, grade: grade)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
