//
//  GradesAtDatesCellView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.11.22.
//

import SwiftUI

struct GradesAtDatesCellView: View {
    var participantCount: Int
    var studentCount: Int
    var onlyStudent: Student?
    var date: Date
    var averageGrade: String
    var color: Color
    var ageGroup: AgeGroup
    var comment: String?
    
    var body: some View {
        HStack {
            Text(date.asString(format: "dd MMM HH:mm"))
            Spacer()
            Text(comment ?? "ver. Kommentare")
            Spacer()
            
            if let onlyStudent, participantCount == 1 {
      
                Image(systemName: "person")
                if let firstLetter = onlyStudent.lastName.first {
                    Text("\(onlyStudent.firstName) \(String(firstLetter))")
                } else {
                    Text("\(onlyStudent.firstName)")
                }
                
            } else {
                Image(systemName: "person.3.sequence")
                Text("\(participantCount) / \(studentCount)")
            }
            Image(systemName: "sum")
            Text(averageGrade)
                .foregroundColor(color)
                .frame(minWidth: 40)
                .padding(5.0)
                .background(.gray)
                .cornerRadius(5.0)
        }
    }
}

