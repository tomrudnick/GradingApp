//
//  SendEmailsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import SwiftUI


struct SendEmailsView<Model: SendEmailProtocol>: View {
    
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var emailViewModel: Model
    @State var showProgressbar = false
    @State var doubleValue = 0.0
    @State var showErrorAlert = false
    @State var showSuccessAlert = false
    @State var errorMessage = ""
    @State var showHeadlines = true
    
    private let title: String

    
    init(title: String, emailViewModel: Model) {
        self.emailViewModel = emailViewModel
        self.title = title
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    EmailEditorView(emailViewModel: emailViewModel, showHeadlines: $showHeadlines)
                }
                .alert(isPresented: $showErrorAlert, content: {
                    Alert(title: Text("Fehler"), message: Text(errorMessage), dismissButton: .default(Text("Ok!")))
                })
                .alert("Alle Emails wurden versendet", isPresented: $showSuccessAlert) {
                    Button("Ok") {
                        self.emailViewModel.subject = ""
                        self.emailViewModel.emailText = ""
                        self.dismiss()
                    }
                }
                .navigationBarTitle(Text("Mail an: \(title)"), displayMode: .inline)
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text(showHeadlines ? "Abbrechen": "")
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            sendEmails()
                        }, label: {
                            Text(showHeadlines ? "Send...": "")
                        }).disabled(!self.emailViewModel.atLeastOneRecipientActive())
                    }
                })
                if showProgressbar {
                    ProgressView(value: doubleValue, total: 1.0)
                        .padding()
                        .padding(.vertical, 30.0)
                        .background(Color.init(red: 0.9, green: 0.9, blue: 0.9))
                        .cornerRadius(10.0)
                        .padding()
                }
            }
        }
    }
    
    func sendEmails() {
        self.showProgressbar = true
        emailViewModel.send { progress in
            doubleValue = progress
        } completionHandler: { failed in
            self.showProgressbar = false
            if failed.count == 0 {
                self.showSuccessAlert.toggle()
            } else {
                self.showErrorAlert.toggle()
                if failed.count == 1 {
                    errorMessage = "Folgende Email konnte nicht versendet werden:"
                } else {
                    errorMessage = "Die \(failed.count) folgenden Emails konnten nicht versendet werden:"
                }
                for failedMail in failed {
                    if let failedUser = failedMail.0.to.first {
                        errorMessage += "\n\(failedUser.name ?? "-"): \(failedUser.email)"
                    }
                }
                
            }
        }
    }
}

