//
//  ButtonCancelView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.08.21.
//

import SwiftUI

struct ButtonCancelView: View {
    
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text("Abbrechen")
        }
    }
}

struct ButtonCancelView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonCancelView()
    }
}
