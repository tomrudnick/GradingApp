//
//  SendEmailsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import SwiftUI
import HighlightedTextEditor


struct SendEmailsView<Model: SendEmailProtocol>: View {
    
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var emailViewModel: Model
    @State var showProgressbar = false
    @State var doubleValue = 0.0
    @State var showErrorAlert = false
    @State var errorMessage = ""
    
    private var title: String

    
    init(title: String, emailViewModel: Model) {
        self.emailViewModel = emailViewModel
        self.title = title
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    EmailEditorView(emailViewModel: emailViewModel)
                }
                .alert(isPresented: $showErrorAlert, content: {
                    Alert(title: Text("Fehler"), message: Text(errorMessage), dismissButton: .default(Text("Ok!")))
                })
                .navigationBarTitle(Text("Mail an: \(title)"), displayMode: .inline)
                .toolbar(content: {
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Abbrechen")
                        })
                    }
                    ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                        Button(action: {
                            self.showProgressbar = true
                            emailViewModel.send { progress in
                                doubleValue = progress
                            } completionHandler: { failed in
                                self.showProgressbar = false
                                if failed.count == 0 {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    self.showErrorAlert.toggle()
                                    if failed.count == 1 {
                                        errorMessage = "Es konnte eine Email nicht versendet werden"
                                    } else {
                                        errorMessage = "Es konnten \(failed.count) Emails nicht versendet werden"
                                    }
                                    
                                }
                            }
                        }, label: {
                            Text("Send...")
                        })
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
}

