//
//  AddSingleGradeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.08.21.
//

import SwiftUI

struct AddSingleGradeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var student: Student
    
    var body: some View {
        SingleGradeView(student: student) { points, type, multiplier, date, comment in
            Grade.addGrade(value: points, date: date, half: HalfType.firstHalf, type: type, comment: comment, multiplier: multiplier, student: student, context: self.viewContext)
        }
    }
}

//----------------------------Preview-------------------------------

struct AddSingleGradeView_Previews: PreviewProvider {
    
    static let student = previewData(context: PersistenceController.preview.container.viewContext).first!.studentsArr.first!
    
    static var previews: some View {
        AddSingleGradeView(student: student)
    }
}

