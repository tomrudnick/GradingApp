//
//  StudentTextfieldView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.08.21.
//

import SwiftUI

struct StudentTextfieldView: View {
    
    var label: String
    var input: Binding<String>
    
    
    var body: some View {
        TextField(label, text: input)
            .padding(.horizontal)
            .frame(height: 55)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

//struct StudentTextfieldView_Previews: PreviewProvider {
//    static var previews: some View {
//        StudentTextfieldView()
//    }
//}
