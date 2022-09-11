//
//  SchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.09.22.
//

import SwiftUI

struct SchoolYearsView: View {
    
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: SchoolYear.fetchAll(), animation: .default)
    private var schoolYear: FetchedResults<SchoolYear>
    
    @State private var showAddSchoolYear = false
    
    @ObservedObject var schoolYearVM : SchoolYearViewModel
    
    
    var body: some View {
        VStack{
            List {
                ForEach(schoolYear, id: \.self) { schoolYear in
                    Button {
                        schoolYearVM.update(newSchoolYear: schoolYear.name)
                    } label: {
                        HStack {
                            Text("\(schoolYear.name)")
                            Spacer()
                            if schoolYearVM.schoolYear == schoolYear.name {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    addButton
                }
            })
            .sheet(isPresented: $showAddSchoolYear) {
                AddSchoolYear()
            }
        }
    }
    var addButton : some View {
        Button {
            showAddSchoolYear = true
        } label: {
            Image(systemName: "plus.circle").font(.largeTitle)
        }
    }
}

//struct SchoolYearsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolYearsView()
//    }
//}


//HStack {
//    Text("\(schoolYear.name)")
//}
