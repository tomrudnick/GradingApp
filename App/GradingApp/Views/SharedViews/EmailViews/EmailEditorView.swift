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
    

    
    @ObservedObject var emailVM: Model
    
    @State var selectionRange = NSMakeRange(0, 0)
    @State private var emailsubject = ""
    @State private var emailText = ""
    @State private var templateName = ""
    @State private var editTemplates = false
    @State var fontSize = UIFontMetrics(forTextStyle: .body)
                            .scaledValue(for: UIFont.preferredFont(forTextStyle: .body).pointSize)
    
    private let tags: NSRegularExpression
    
    private var editMode: EditMode {
        editTemplates ? .active : .inactive
    }
    
    init(emailViewModel: Model) {
        self.emailVM = emailViewModel
        let tags = try! NSRegularExpression(pattern: emailViewModel.regexString, options: [])
        self.tags = tags
    }
    
    var body: some View {
        Form {
            Section(content: {
                if editTemplates {
                    ForEach(emailTemplates){ template in
                        Text(template.templateName)
                    }
                    .onDelete(perform: removeTemplate)
                    .onMove(perform: move)
                } else {
                    ScrollView(.horizontal){
                        HStack(spacing: 20) {
                            ForEach(emailTemplates){ template in
                                Button {
                                    emailVM.subject = template.emailSubject
                                    emailVM.emailText = template.emailText
                                } label: {
                                    Text(template.templateName)
                                        .padding(10)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10.0)
                                }
                            }
                        }
                    }
                }
            }, header: {
                HStack{
                    Text("Vorlage")
                    Spacer()
                    Button {
                        withAnimation {
                            editTemplates.toggle()
                        }
                    } label: {
                        Text(editTemplates ? "Done" : "Edit")
                    }
    
                }
            })
            if editTemplates == false {
                Section("Empfänger") {
                    EmailRecipientToggleView(emailVM: emailVM)
                }
            }
            Section(header: Text("Betreff")) {
                TextField("Subject....", text: $emailVM.subject)
            }
            if editTemplates == false {
                Section(header: Text("Variablen")) {
                    TagScrollView(emailVM: emailVM, selectionRange: $selectionRange)
                }
            }
            Section(header: Text("Email Text")) {
                textEditor
            }
            Section(header: Text("Als Vorlage speichern")){
                HStack{
                    TextField("Name der Vorlage", text: $templateName)
                    Spacer()
                    Button("Add", action: addTemplate)
                        .disabled(templateName.isEmpty)
                }
            }
        }.environment(\.editMode, Binding.constant(editMode))
    }
   

    
    var textEditor: some View {
        TextEditor(fontSize: $fontSize, message: $emailVM.emailText, selectionRange: $selectionRange, regex: tags).frame(height: 500)
    }
    
    
    func addTemplate() {
        _ = EmailTemplate(index: emailTemplates.count + 1, templateName: templateName, emailText: emailVM.emailText, emailSubject: emailVM.subject, context: viewContext)
        templateName = ""
        viewContext.perform {
            try? viewContext.save()
        }
    }
    func removeTemplate(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(emailTemplates[index])
        }
        viewContext.perform {
            try? viewContext.save()
        }
    }
    func move(from source: IndexSet, to destination: Int) {
        var arrayOfTemplates: [EmailTemplate] = Array(emailTemplates)
        arrayOfTemplates.move(fromOffsets: source, toOffset: destination)
        for (index, template) in arrayOfTemplates.enumerated() {
            if template.index != Int16(index) {
                template.index = Int16(index)
            }
        }
        viewContext.perform {
            try? viewContext.save()
        }
    }
}

