//
//  CustomButtonView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.08.21.
//

import SwiftUI

struct CustomButtonView: View {
    var label: String
    var action: () -> Void
    var buttonColor: Color
    var body: some View {
        Button(action: self.action, label: {
            Text(label)
                .foregroundColor(.white)
                .font(.headline)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(buttonColor)
                .cornerRadius(10)
        })
        .padding()
    }
}

//----------------------------Preview-------------------------------
struct CustomButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CustomButtonView(label: "Hinzufügen", action: {
        }, buttonColor: .blue)
    }
}
