//
//  GradeDetailView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//

import SwiftUI

struct GradeDetailView: View {
    
    @ObservedObject var student: Student
    var gradeType: GradeType
    
    
    var body: some View {
        VStack {
            List {
                ForEach(student.gradesArr) { grade in
                    if grade.type == gradeType {
                        NavigationLink(destination: EditSingleGradeView(student: student, grade: grade)) {
                            HStack {
                                VStack {
                                    Text(Grade.convertGradePointsToGrades(value: Int(grade.value)))
                                    Text(String(grade.multiplier)).font(.footnote)
                                }
                            
                                Text(grade.dateAsString())
                                Text(grade.comment ?? "")
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(Text(gradeType == .oral ? "Mündliche Noten \(student.firstName) \(student.lastName)": "Schriftliche Noten \(student.firstName) \(student.lastName)"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GradeDetailView_Previews: PreviewProvider {
    

    static var previews: some View {
        let student = (previewData(context: PersistenceController.preview.container.viewContext).first(where: {$0.name == "Mathe 10FLS"})?.studentsArr.first!)!
        
        NavigationView {
            GradeDetailView(student: student , gradeType: .oral)
        }
    }
}
