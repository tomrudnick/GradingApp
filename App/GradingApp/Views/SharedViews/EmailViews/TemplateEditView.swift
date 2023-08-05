//
//  TemplateEditView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 01.08.23.
//

import SwiftUI

struct TemplateEditView<Model: SendEmailProtocol>: View {
    
    @Environment (\.managedObjectContext) var viewContext
    
    @ObservedObject var emailVM: Model
    var editTemplates: Bool
    @Binding var selectedTemplate: Int?
    
    
    @FetchRequest(fetchRequest: EmailTemplate.fetchAll(), animation: .default)
    var emailTemplates: FetchedResults<EmailTemplate>
    
    
    var body: some View {
        if editTemplates {
            ForEach(emailTemplates){ template in
                Button {
                    updateTemplate()
                    emailVM.subject = template.emailSubject
                    emailVM.emailText = template.emailText
                    selectedTemplate = Int(template.index)
                } label: {
                    Text(template.templateName)
                        .padding(10)
                        .foregroundColor(.white)
                        .background(selectedTemplate == Int(template.index) ? Color.yellow : Color.blue)
                        .cornerRadius(10.0)
                }
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
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
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
    
    func updateTemplate() {
        guard let selectedTemplate else { return }
        guard let template = emailTemplates.first(where: { $0.index == Int16(selectedTemplate) }) else { return }
        
        template.emailText = emailVM.emailText
        template.emailSubject = emailVM.subject
        viewContext.perform {
            try? viewContext.save()
        }
    }
}
