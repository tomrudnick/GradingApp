//
//  EmailEditorView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import SwiftUI

struct EmailEditorView<Model: SendEmailProtocol>: View {
    
    @Environment (\.managedObjectContext) var viewContext

    @FetchRequest(fetchRequest: EmailTemplate.fetchAll(), animation: .default)
    var emailTemplates: FetchedResults<EmailTemplate>
    

    
    @ObservedObject var emailVM: Model
    
    @State var selectionRange = NSMakeRange(0, 0)
    @State private var emailsubject = ""
    @State private var emailText = ""
    @State private var templateName = ""
    @State private var editTemplates = false
    @State var fontSize = UIFontMetrics(forTextStyle: .body)
                            .scaledValue(for: UIFont.preferredFont(forTextStyle: .body).pointSize)
    @Binding var showHeadlines: Bool
    
    private let tags: NSRegularExpression
    
    private var editMode: EditMode {
        editTemplates ? .active : .inactive
    }
    
    init(emailViewModel: Model, showHeadlines: Binding<Bool>) {
        self.emailVM = emailViewModel
        let tags = try! NSRegularExpression(pattern: emailViewModel.regexString, options: [])
        self.tags = tags
        self._showHeadlines = showHeadlines
    }
    
    var body: some View {
        Form {
            Section(content: {
                TemplateEditView(emailVM: emailVM, editTemplates: editTemplates)
            }, header: {
                HStack{
                    Text("Vorlage")
                    Spacer()
                    Button {
                        withAnimation {
                            editTemplates.toggle()
                        }
                        showHeadlines.toggle()
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
}

