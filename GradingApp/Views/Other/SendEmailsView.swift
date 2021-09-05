//
//  SendEmailsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import SwiftUI
import HighlightedTextEditor





struct SendEmailsView: View {
    
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var course: Course
    @ObservedObject var emailViewModel: SendMultipleEmailsViewModel
    @State var showProgressbar = false
    @State var doubleValue = 0.0
    @State var showErrorAlert = false
    @State var errorMessage = ""
    

    
    init(course: Course, emailViewModel: SendMultipleEmailsViewModel) {
        self.course = course
        self.emailViewModel = emailViewModel
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
                .navigationBarTitle(Text("Mail an: \(course.name)"), displayMode: .inline)
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
                            emailViewModel.sendEmails(course: course, half: halfYear) { progress in
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

