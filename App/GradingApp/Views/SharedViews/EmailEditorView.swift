//
//  EmailEditorView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import SwiftUI
import HighlightedTextEditor

struct EmailEditorView<Model: SendEmailProtocol>: View {
    
    @Environment (\.managedObjectContext) var viewContext

    @FetchRequest(fetchRequest: EmailTemplate.fetchAll(), animation: .default)
    private var emailTemplates: FetchedResults<EmailTemplate>
    
    
    
    @ObservedObject var emailViewModel: Model
    
    
    @State var selectionRange = NSMakeRange(0, 0)
    @State var senderMenuExpanded: Bool = false
    
    @State private var emailsubject = ""
    @State private var emailText = ""
    @State private var templateName = ""
    @State private var editTemplates = false
    
    
    
    
    private let tags: NSRegularExpression
    @State var fontSize = UIFontMetrics(forTextStyle: .body).scaledValue(for: UIFont.preferredFont(forTextStyle: .body).pointSize)
    
    init(emailViewModel: Model) {
        self.emailViewModel = emailViewModel
        let tags = try! NSRegularExpression(pattern: emailViewModel.regexString, options: [])

        self.tags = tags
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: HStack{
                    Text("Vorlagen")
                    Spacer()
                    Button(editTemplates ? "Done" : "Edit"){
                        withAnimation {
                            editTemplates.toggle()
                        }
                    }
                }){ if editTemplates {
                    TemplateEditView(emailTemplates: emailTemplates)
                        .environment(\.editMode, Binding.constant(EditMode.active))
                } else {
                    ScrollView(.horizontal){
                        HStack(spacing: 20) {
                            ForEach(emailTemplates){ template in
                                Button {
                                    emailViewModel.subject = template.emailSubject ?? ""
                                    emailViewModel.emailText = template.emailText ?? ""
                                } label: {
                                    Text(template.templateName ?? "Error")
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10.0)
                                }
                            }
                        }
                    }
                }
                }
                
                if editTemplates == false {
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
                }
                Section(header: Text("Betreff")) {
                    TextField("Subject....", text: $emailViewModel.subject)
                }
                if editTemplates == false {
                    Section(header: Text("Variablen")) {
                        tagScrollView
                    }
                }
                Section(header: Text("Email Text")) {
                    textEditor
                }
                Section(header: Text("Als Vorlage speichern")){
                    HStack{
                        TextField("Name der Vorlage", text: $templateName)
                        Spacer()
                        Button {
                            _ = EmailTemplate(index: emailTemplates.count + 1, templateName: templateName, emailText: emailViewModel.emailText, emailSubject: emailViewModel.subject, context: viewContext)
                            try? viewContext.save()
                        } label: {
                            Text("Add")
                        } .disabled(templateName.isEmpty)
                    }
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
                ForEach(emailViewModel.emailKeys, id: \.self) { key in
                    Button(action: {
                        let selectionRange = selectionRange
                        print("From: \(selectionRange.lowerBound) to \(selectionRange.upperBound)")
                        let lowerIndex = emailViewModel.emailText.index(emailViewModel.emailText.startIndex, offsetBy: selectionRange.lowerBound)
                        let upperIndex = emailViewModel.emailText.index(emailViewModel.emailText.startIndex, offsetBy: selectionRange.upperBound)
                        emailViewModel.emailText.replaceSubrange(lowerIndex..<upperIndex, with: "<\(key)>")
                        self.selectionRange = NSMakeRange(selectionRange.lowerBound + key.count + 1, selectionRange.upperBound - selectionRange.lowerBound)
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
        TextEditor(fontSize: $fontSize, message: $emailViewModel.emailText, selectionRange: $selectionRange, regex: tags).frame(height: 500)
    }
}

