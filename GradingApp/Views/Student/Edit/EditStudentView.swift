//
//  EditStudentView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 16.08.21.
//

import SwiftUI

struct EditStudentView: View {
    
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    
    var body: some View {
        VStack {
            CustomTextfieldView(label: "Vorname", input: $firstName)
            CustomTextfieldView(label: "Nachname", input: $lastName)
            CustomTextfieldView(label: "Email", input: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            Spacer()
        }
    }
}

/*struct EditStudentView_Previews: PreviewProvider {
    static var previews: some View {
        EditStudentView()
    }
}*/
