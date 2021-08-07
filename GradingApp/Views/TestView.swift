//
//  TestView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.08.21.
//

import SwiftUI

struct User: Identifiable {
    var id = "Taylor Swift"
}

struct TestView: View {
    @State private var selectedUser: User? = nil
    @State private var isShowingAlert = false

    var body: some View {
        Text("Hello, World!")
            .onTapGesture {
                self.selectedUser = User()
                self.isShowingAlert = true
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Hallo"))
            }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
