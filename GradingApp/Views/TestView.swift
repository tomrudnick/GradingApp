//
//  SwiftUIView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 16.07.21.
//

import SwiftUI

struct VStackAlignmentView: View {
    
    
    var body: some View {
        Image("logo_nige")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
    }
}
struct MyContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStackAlignmentView()
    }
}
