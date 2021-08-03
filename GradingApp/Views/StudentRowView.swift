//
//  StudentRowView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 17.07.21.
//

import SwiftUI

struct StudentRowView: View {
    
    var student: Student
    
    
    var body: some View {
        
        NavigationLink( destination: StudentView().navigationBarTitle(student.firstName + " " + student.lastName) ){
            HStack{
                Text(student.firstName)
                    .frame(width: 80, alignment: .leading)
                Text(student.lastName)
                    .frame(width: 120, alignment: .leading)
            }
        }
    }
}
struct StudentRowView_Previews: PreviewProvider {
    static var previews: some View {

        StudentRowView(student: Student(firstName: "Matthias", lastName: "Rudnick", email: "matthias@rudnick.ch", course: nil))
            .previewLayout(.fixed(width: 300, height: 50))
    }
}


