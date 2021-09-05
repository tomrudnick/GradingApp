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
    @ObservedObject var emailViewModel: EmailViewModel
    @State var emailText = "Hallo $firstName $lastName du hast Mündlich: $oralGrade, und Schriftlich: $writtenGrade und gesamt $grade"
    @State var showProgressbar = false
    @State var doubleValue = 0.0
    @State var showErrorAlert = false
    @State var errorMessage = ""
    @State var selectionRange: NSRange?
    @State var subject = ""
    
    private let tags: NSRegularExpression
    private let rules: [HighlightRule]
    
    init(course: Course, emailViewModel: EmailViewModel) {
        self.course = course
        self.emailViewModel = emailViewModel
        let tags = try! NSRegularExpression(pattern: emailViewModel.regexString, options: [])
        self.rules = [
            HighlightRule(pattern: tags, formattingRules: [
                TextFormattingRule(key: .backgroundColor, value: UIColor(red: 0, green: 0, blue: 0.85, alpha: 0.35)),
                TextFormattingRule(fontTraits: [.traitItalic]),
                ])
        ]
        self.tags = tags
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Betreff")) {
                            TextField("Subject....", text: $subject)
                        }
                        Section(header: Text("Tags")) {
                            ScrollView(.horizontal) {
                                HStack(spacing: 20) {
                                    ForEach(emailViewModel.emailKeys.map( {string in string[string.range(of: "\\$")!.upperBound...]}), id: \.self) { key in
                                        Button(action: {
                                            if let selectionRange = selectionRange{
                                                print("From: \(selectionRange.lowerBound) to \(selectionRange.upperBound)")
                                                let lowerIndex = emailText.index(emailText.startIndex, offsetBy: selectionRange.lowerBound)
                                                let upperIndex = emailText.index(emailText.startIndex, offsetBy: selectionRange.upperBound)
                                                emailText.replaceSubrange(lowerIndex..<upperIndex, with: "$\(key)")
                                                self.selectionRange = NSMakeRange(selectionRange.lowerBound + key.count + 1, selectionRange.upperBound - selectionRange.lowerBound)
                                            }
                                        }, label: {
                                            Text(key)
                                                .padding()
                                                .foregroundColor(.white)
                                                .background(Color.blue)
                                                .cornerRadius(10.0)
                                                //.foregroundColor(.white)
                                                //.padding()
                                                //.background(UIColor.blue)
                                        })
                                    }
                                }
                                .padding()
                                //Spacer().frame(height: 20)
                            }
                        }
                        
                        Section(header: Text("Email Text")) {
                            HighlightedTextEditor(text: $emailText, highlightRules: rules)
                            .onCommit { print("commited") }
                            .onEditingChanged { print("editing changed") }
                            .onTextChange { print("latest text value", $0) }
                            .onSelectionChange { (range: NSRange) in
                                print(range)
                                self.selectionRange = range
                                print(emailViewModel.regexString)
                            }
                            .introspect { editor in
                                if let range = selectionRange {
                                    let lowerPosition = editor.textView.position(from: editor.textView.beginningOfDocument, offset: range.lowerBound)!
                                    editor.textView.selectedTextRange = editor.textView.textRange(from: lowerPosition, to: lowerPosition)
                                }
                            }.frame(height: 500)
                        }
                    }
                    
                    
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
                            emailViewModel.sendEmails(subject: subject, emailText: self.emailText, course: course, half: halfYear) { progess in
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
                                        errorMessage = "Es konnten \(failed.count) Emails nicht versendet werden"
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

