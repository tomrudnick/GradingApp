//
//  EmailEditorView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import SwiftUI
import HighlightedTextEditor

struct EmailEditorView<Model: SendEmailProtocol>: View {
    
    @ObservedObject var emailViewModel: Model
    
    @State var selectionRange: NSRange?
    @State var senderMenuExpanded: Bool = false
    
    private let tags: NSRegularExpression
    private let rules: [HighlightRule]
    
    init(emailViewModel: Model) {
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
        VStack {
            Form {
                //Absender: alle Schüler des Kurses
                //Absender: ausgewählte Schüler
                Section(header: Text("Absender")) {
                    VStack{
                        HStack{
                            Text("alle Schüler")
                            Spacer()
                            Button {
                                senderMenuExpanded.toggle()
                            } label: {
                                Image(systemName: senderMenuExpanded ? "chevron.up" : "chevron.down")
                            }

                        }
                        if senderMenuExpanded {
                            List {
                                //ForEach(emailViewModel.students){ (key,value) in
                                //HStack{
                                    //Text(key)
                                    //Spacer()
                                 // Text(value)
                                //}
                                //}
                            }
                        }
                    }
                    
                }
                Section(header: Text("Betreff")) {
                    TextField("Subject....", text: $emailViewModel.subject)
                }
                Section(header: Text("Tags")) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            ForEach(emailViewModel.emailKeys.map( {string in string[string.range(of: "\\$")!.upperBound...]}), id: \.self) { key in
                                Button(action: {
                                    if let selectionRange = selectionRange{
                                        print("From: \(selectionRange.lowerBound) to \(selectionRange.upperBound)")
                                        let lowerIndex = emailViewModel.emailText.index(emailViewModel.emailText.startIndex, offsetBy: selectionRange.lowerBound)
                                        let upperIndex = emailViewModel.emailText.index(emailViewModel.emailText.startIndex, offsetBy: selectionRange.upperBound)
                                        emailViewModel.emailText.replaceSubrange(lowerIndex..<upperIndex, with: "$\(key)")
                                        self.selectionRange = NSMakeRange(selectionRange.lowerBound + key.count + 1, selectionRange.upperBound - selectionRange.lowerBound)
                                    }
                                }, label: {
                                    Text(key)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10.0)
                                })
                            }
                        }
                        .padding()
                    }
                }
                
                Section(header: Text("Email Text")) {
                    HighlightedTextEditor(text: $emailViewModel.emailText, highlightRules: rules)
                    .onCommit { print("commited") }
                    .onEditingChanged { print("editing changed") }
                    .onTextChange { print("latest text value", $0) }
                    .onSelectionChange { (range: NSRange) in
                        print(range)
                        self.selectionRange = range
                        print(emailViewModel.regexString)
                    }
                    .introspect { editor in
                        editor.textView.autocorrectionType = .no
                        if let range = selectionRange,  let lowerPosition = editor.textView.position(from: editor.textView.beginningOfDocument, offset: range.lowerBound) {
                            editor.textView.selectedTextRange = editor.textView.textRange(from: lowerPosition, to: lowerPosition)
                        }
                    }.frame(height: 500)
                }
            }
            
            
        }
    }
}
