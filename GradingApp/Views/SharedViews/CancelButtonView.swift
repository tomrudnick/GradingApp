//
//  CancelButtonView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.08.21.
//

import SwiftUI

struct CancelButtonView: View {
    
    @Environment(\.presentationMode) var presentationMode
    var label: String

    
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(label)
        }
    }
}
struct CancelButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CancelButtonView(label: "Abbrechen")
    }
}
