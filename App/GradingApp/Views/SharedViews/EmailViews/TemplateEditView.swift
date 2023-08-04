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
    @State var isSelected = -1
    
    
    @FetchRequest(fetchRequest: EmailTemplate.fetchAll(), animation: .default)
    var emailTemplates: FetchedResults<EmailTemplate>
    
    
    var body: some View {
        if editTemplates {
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
