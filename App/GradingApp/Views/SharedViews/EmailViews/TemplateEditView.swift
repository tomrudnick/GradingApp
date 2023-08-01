//
//  TemplateEditView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 01.08.23.
//

import SwiftUI

struct TemplateEditView: View {

    var emailTemplates: FetchedResults<EmailTemplate>
    
    var body: some View {
        ForEach(emailTemplates){ template in
            Text(template.templateName ?? "")
        }
        .onDelete(perform: {_ in })
        .onMove(perform: {_,_ in })
    }
}
