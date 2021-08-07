//
//  StudentTextfieldView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.08.21.
//

import SwiftUI

struct CustomTextfieldView: View {
    
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

struct CustomTextfieldView_Previews: PreviewProvider {
    
    @State static var testBinding = ""
    
    static var previews: some View {
        CustomTextfieldView(label: "Vorname", input: $testBinding)
    }
}
