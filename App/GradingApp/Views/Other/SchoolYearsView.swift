//
//  SchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.09.22.
//

import SwiftUI

struct SchoolYearsView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showAddSchoolYear = false

    
    
    var body: some View {
        VStack{
            List{
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
        .sheet(isPresented: $showAddSchoolYear) {
            AddSchoolYear()
        }
    }
    var addButton : some View {
                     Button {
                         showAddSchoolYear = true
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
