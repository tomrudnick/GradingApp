//
//  GradeDetailView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//

import SwiftUI

struct GradeDetailView: View {
    
    @Environment(\.currentHalfYear) var halfYear
    
    @ObservedObject var student: Student
    
    var gradeType: GradeType
    
    
    var body: some View {
        VStack {
            List {
                ForEach(student.gradesArr) { grade in
                    if grade.type == gradeType && grade.half == halfYear {
                        NavigationLink(destination: EditSingleGradeView(student: student, grade: grade)) {
                            HStack {
                                if grade.multiplier != 1.0 {
                                    VStack {
                                        Text(grade.toString())
                                        Text(String(grade.multiplier)).font(.footnote)
                                    }
                                } else {
                                    Text(grade.toString())
                                }
                                
                                Spacer()
                                Text(grade.dateAsString())
                                Text(grade.comment ?? "")
                            }
                        }
                    }
                }.onDelete { indexSet in
                    Grade.delete(at: indexSet, for: student.gradesArr)
                }
            }
        }
        .navigationTitle(Text("\(halfYear == .firstHalf ? "1. " : "2. ")\(gradeType == .oral ? "Mündliche Noten" : "Schrifltiche Note") \(student.firstName) \(student.lastName)"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GradeDetailView_Previews: PreviewProvider {
    

    static var previews: some View {
        let student = (previewData(context: PersistenceController.preview.container.viewContext).first(where: {$0.name == "Mathe 10FLS"})?.studentsArr.first!)!
        
        NavigationView {
            GradeDetailView(student: student , gradeType: .oral).environment(\.currentHalfYear, .firstHalf)
        }
    }
}
