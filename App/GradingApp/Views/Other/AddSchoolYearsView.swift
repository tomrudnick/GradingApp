//
//  AddSchoolYear.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.09.22.
//

import SwiftUI
import CSV

struct AddSchoolYearsView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ChangeSchoolYearsView(schoolYearName_: "", title: "Neues Schuljahr") { schoolYearName in
            SchoolYear.addSchoolYear(name: schoolYearName, context: viewContext)
        }
    }
}

//struct AddSchoolYear_Previews: PreviewProvider {
//    static var previews: some View {
//        AddSchoolYear()
//    }
//}
