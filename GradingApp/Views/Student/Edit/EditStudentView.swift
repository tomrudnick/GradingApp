//
//  EditStudentView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 16.08.21.
//

import SwiftUI

struct EditStudentView: View {
    
    @Binding var student: Student.DataModel
    
    var body: some View {
        VStack {
            SingleStudent(viewTitle: "Schüler bearbeiten", student: student) {
                student in
                self.student.update(for: student)
            }
        }
    }
}

/*struct EditStudentView_Previews: PreviewProvider {
    static var previews: some View {
        EditStudentView()
    }
}*/



