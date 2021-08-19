//
//  EditStudentView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 16.08.21.
//

import SwiftUI

struct EditStudentView: View {
    
    @Binding var oldStudent: Student.DataModel
    
    var body: some View {
        VStack {
            SingleStudent(viewTitle: "Schüler bearbeiten", student: oldStudent) {
                newStudent in
                self.oldStudent = newStudent
            }
        }
    }
}

/*struct EditStudentView_Previews: PreviewProvider {
    static var previews: some View {
        EditStudentView()
    }
}*/



