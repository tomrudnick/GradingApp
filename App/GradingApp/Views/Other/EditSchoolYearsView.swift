//
//  EditSchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 12.09.22.
//

import SwiftUI

struct EditSchoolYearsView: View {
    
    @ObservedObject var oldSchoolYear: SchoolYear
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ChangeSchoolYearsView(schoolYearName_: oldSchoolYear.name, title: "Schuljahr umbennen") { newName in
            oldSchoolYear.name = newName
            self.viewContext.saveCustom()
        }
    }
}
    
