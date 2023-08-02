//
//  EmailRecipientToggleView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 01.08.23.
//

import SwiftUI

struct EmailRecipientToggleView<Model: SendEmailProtocol>: View {
    @ObservedObject var emailVM: Model
    @State var senderMenuExpanded: Bool = false
    
    var body: some View {
        if self.emailVM.recipients.count == 1 {
            oneRecipient
        } else {
            VStack {
                multipleRecipientSelectMenu
                if senderMenuExpanded {
                    List { allRecipientsList }
                }
            }
        }
    }
    
    
    @ViewBuilder
    var oneRecipient: some View {
        let recipient = self.emailVM.recipients.first?.key
        if let recipient {
            Text("\(recipient.firstName) \(recipient.lastName)")
        } else {
            Text("-")
        }
    }
    
    @ViewBuilder
    var multipleRecipientSelectMenu: some View {
        HStack{
            Text(!self.emailVM.atLeastOneRecipientInActive() ? "Alle Schüler" :
                "\(self.emailVM.selectedRecipients) Schüler")
            Spacer()
            if senderMenuExpanded {
                toggleAllRecpientsButton
                    .foregroundColor(Color.black)
                    .buttonStyle(.bordered)
            }
            Image(systemName: senderMenuExpanded ? "chevron.up" : "chevron.down").onTapGesture {
                senderMenuExpanded.toggle()
            }
        }.padding([.bottom, .top])
    }
    
    @ViewBuilder
    var allRecipientsList: some View {
        ForEach(emailVM.recipientsSorted, id: \.key) { student, value in
            HStack {
                Text("\(student.firstName) \(student.lastName)")
                Spacer()
                Image(systemName: (self.emailVM.recipients[student] ?? false) ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .onTapGesture {
                        if let value = self.emailVM.recipients[student] {
                            self.emailVM.recipients[student] = !value
                        }
                    }
            }.padding(.bottom)
        }
    }
    
    var toggleAllRecpientsButton: some View {
        Button {
            self.emailVM.toggleAllRecipients()
        } label: {
            if !self.emailVM.atLeastOneRecipientInActive() {
                Text("Alle abwählen")
            } else {
                Text("Alle auswählen")
            }
        }
    }

}

