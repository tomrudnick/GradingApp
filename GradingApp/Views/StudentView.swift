//
//  StudentView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct StudentView: View {
    
    @ObservedObject var student: Student
    
    var body: some View {
        Text("Data of Student").navigationTitle(Text(student.firstName))
    }
}

/*struct StudentView_Previews: PreviewProvider {
    static var previews: some View {
        StudentView()
    }
}*/
