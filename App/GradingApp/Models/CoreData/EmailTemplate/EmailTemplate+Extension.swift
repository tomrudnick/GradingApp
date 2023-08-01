//
//  EmailTemplate+Extension.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 28.07.23.
//

import Foundation
import CoreData

extension EmailTemplate{
    convenience init(index: Int, templateName: String, emailText: String, emailSubject: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.index = Int16(index)
        self.templateName = templateName
        self.emailSubject = emailSubject
        self.emailText = emailText
    }
    
    static func fetchAll() -> NSFetchRequest<EmailTemplate> {
        let request = NSFetchRequest<EmailTemplate>(entityName: "EmailTemplate")
        request.sortDescriptors = []
        return request
    }
}
