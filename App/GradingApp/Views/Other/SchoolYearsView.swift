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
    @FetchRequest(fetchRequest: SchoolYear.fetchAll(), animation: .default) private var schoolYear: FetchedResults<SchoolYear>
    
    
    @State private var selectedSchoolYear : SchoolYear? = nil
    
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
                    .swipeActions(allowsFullSwipe: false) {
                        Button {
                            selectedSchoolYear = schoolYear
                        } label: {
                            Label("Bearbeiten", systemImage: "pencil")
                        }.tint(Color.accentColor)
                        Button(role: .destructive) {
                            viewContext.delete(schoolYear)
                            viewContext.saveCustom()
                        } label: {
                           Label("Löschen", systemImage: "trash")
                        }.disabled(schoolYearVM.schoolYear == schoolYear.name)
                    }
                }
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    addButton
                }
            })
            .sheet(item: $selectedSchoolYear, content: { schoolYear in
                EditSchoolYearsView(oldSchoolYear: schoolYear, schoolYearVM: schoolYearVM)
            })
            .sheet(isPresented: $showAddSchoolYear) {
                AddSchoolYearsView()
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


