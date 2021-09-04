//
//  SendEmailsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import SwiftUI



struct SendEmailsView: View {
    
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var course: Course
    @StateObject var emailViewModel = EmailViewModel()
    @State var emailText = "Hallo $firstName $lastName du hast Mündlich: $oralGrade, und Schriftlich: $writtenGrade und gesamt $grade"
    @State var showProgressbar = false
    @State var doubleValue = 0.0
    @State var showErrorAlert = false
    @State var errorMessage = ""
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                   TextEditor(text: $emailText)
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
                            emailViewModel.sendEmails(emailText: self.emailText, course: course, half: halfYear) { progess in
                                doubleValue = progess
                            } completionHandler: { failed in
                                self.showProgressbar.toggle()
                                if failed.count == 0 {
                                    self.presentationMode.wrappedValue.dismiss()
                                } else {
                                    self.showErrorAlert.toggle()
                                    if failed.count == 1 {
                                        errorMessage = "Es konnte eine Email nicht versendet werden"
                                    } else {
                                        errorMessage = "Es konnten \(failed.count) Email nicht versendet werden"
                                    }
                                    
                                }
                            }

                            self.showProgressbar.toggle()
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

