//
//  SchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.09.22.
//

import SwiftUI

struct SchoolYearsView: View {
    var body: some View {
        VStack{
            List{
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Text("Hello, World!")
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                addButton
            }
        })
    }
    var addButton : some View {
                     Button {
                         
                     } label: {
                         Image(systemName: "plus.circle").font(.largeTitle)
                     }
                 }
}

struct SchoolYearsView_Previews: PreviewProvider {
    static var previews: some View {
        SchoolYearsView()
    }
}
