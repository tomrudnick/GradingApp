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
                        NavigationLink(value: Route.editGrade(student, grade)) {
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
        .navigationTitle(Text("\(gradeType == .oral ? "Mündliche Noten" : "Schriftliche Noten") \(student.firstName) \(student.lastName)"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
