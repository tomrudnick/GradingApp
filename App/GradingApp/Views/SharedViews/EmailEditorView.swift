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
                Section(header: Text("Empfänger")) {
                    
                    if self.emailViewModel.recipients.count == 1 {
                        Text("\(self.emailViewModel.recipients.first!.key.firstName) \(self.emailViewModel.recipients.first!.key.lastName)")
                    } else {
                        VStack{
                            HStack{
                                Text(!self.emailViewModel.recipients.contains(where: { (key: Student, value: Bool) in
                                    value == false
                                }) ? "Alle Schüler" : "\(self.emailViewModel.recipients.filter{$0.1}.count) Schüler")
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
                            
                            if senderMenuExpanded {
                                List {
                                    allRecipientsList
                                }
                            }
                        }
                    }
                }
                Section(header: Text("Betreff")) {
                    TextField("Subject....", text: $emailViewModel.subject)
                }
                Section(header: Text("Tags")) {
                    tagScrollView
                }
                
                Section(header: Text("Email Text")) {
                    textEditor
                }
            }
            
            
        }
    }
    
    func toggleAllRecipients() {
        if !self.emailViewModel.recipients.contains(where: { $0.value == false }) {
            for key in self.emailViewModel.recipients.keys {
                self.emailViewModel.recipients[key] = false
            }
        } else {
            for key in self.emailViewModel.recipients.keys {
                self.emailViewModel.recipients[key] = true
            }
        }
    }
    
    var allRecipientsList: some View {
        ForEach(emailViewModel.recipients.sorted(by: {$0.0.lastName < $1.0.lastName}), id: \.key) { key, value in
            HStack {
                Text("\(key.firstName) \(key.lastName)")
                Spacer()
                Image(systemName: (self.emailViewModel.recipients[key] ?? false) ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .onTapGesture {
                        if let value = self.emailViewModel.recipients[key] {
                            self.emailViewModel.recipients[key] = !value
                        }
                    }
            }.padding(.bottom)
        }
    }
    
    var toggleAllRecpientsButton: some View {
        Button {
           toggleAllRecipients()
        } label: {
            if !self.emailViewModel.recipients.contains(where: { $0.value == false }) {
                Text("Alle abwählen")
            } else {
                Text("Alle auswählen")
            }
        }
    }
    
    var tagScrollView: some View {
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
    
    var textEditor: some View {
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

