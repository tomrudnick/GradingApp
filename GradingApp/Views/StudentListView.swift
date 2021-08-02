//
//  StudentListView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 16.07.21.
//

import SwiftUI


struct StudentListView: View {
    
    var course: [Student]
    
    var body: some View {
        List{
            ForEach(course) { currentStudent in
                StudentRowView(student: currentStudent)
            }
        }
    }
}


struct StudentListView_Previews: PreviewProvider {
    static var previews: some View {
        StudentListView(course: studentsMathe10FLS)
    }
}

