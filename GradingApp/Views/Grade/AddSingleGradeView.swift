//
//  AddSingleGradeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 06.08.21.
//

import SwiftUI

struct AddSingleGradeView: View {
    
    @ObservedObject var student: Student
    
    var body: some View {
        VStack {
            Text("Add Grade for: \(student.firstName) \(student.lastName)")
            Form {
                
            }
        }.navigationTitle(Text("Add Grade for: \(student.firstName) \(student.lastName)"))
        
    }
}

/*struct AddSingleGradeView_Previews: PreviewProvider {
    static var previews: some View {
        AddSingleGradeView()
    }
}*/
