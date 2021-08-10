//
//  CustomBackButton.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.08.21.
//

import SwiftUI

struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    let buttomTitle: String
    
    init (_ buttomTitle: String = "Zurück") {
        self.buttomTitle = buttomTitle
    }
    
    var body: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.backward") // BackButton Image
                    .aspectRatio(contentMode: .fit)
                Text(buttomTitle) //translated Back button title
            }
        }
    }
}

struct CustomBackButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomBackButton("Test")
    }
}
