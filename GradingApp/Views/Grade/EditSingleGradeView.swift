//
//  EditSingleGradeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//

import SwiftUI

struct EditSingleGradeView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
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
    
    static let previewCourse = previewGeneratorCourse()
    static let previewStudent = previewGeneratorStudent(course: previewCourse)
    static let previewGrade = previewGenerateGrade(student: previewStudent)
    
    static var previews: some View {
        EditSingleGradeView(student: previewStudent, grade: previewGrade)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

func previewGeneratorStudent (course: Course) -> Student {
    let previewStudent = Student(context: PersistenceController.preview.container.viewContext)
    previewStudent.course = course
    previewStudent.firstName = "Marit"
    previewStudent.lastName = "Abken"
    previewStudent.email = "marit.abken@nige.de"
    return previewStudent
}
func previewGeneratorCourse () -> Course {
    let previewCourse = Course(context: PersistenceController.preview.container.viewContext)
    previewCourse.name = "Mathe 6C"
    return previewCourse
}

func previewGenerateGrade (student: Student) -> Grade {
    let previewGrade = Grade(context: PersistenceController.preview.container.viewContext)
    previewGrade.date = Date()
    previewGrade.half = .firstHalf
    previewGrade.type = .oral
    previewGrade.value = 13
    previewGrade.multiplier = 1.0
    previewGrade.student = student
    return previewGrade
}
