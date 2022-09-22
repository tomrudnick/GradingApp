//
//  SchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.09.22.
//

import SwiftUI

struct SchoolYearsView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: SchoolYear.fetchAll(), animation: .default)
    private var schoolYear: FetchedResults<SchoolYear>
        
    @State private var selectedSchoolYear : SchoolYear? = nil
    @State private var showAddSchoolYear = false

    @Binding var activeSchoolYear: String?
    
    var body: some View {
        VStack{
            List {
                ForEach(schoolYear, id: \.self) { schoolYear in
                    Button {
                        activeSchoolYear = schoolYear.name
                    } label: {
                        HStack {
                            Text("\(schoolYear.name)")
                            
                            Spacer()
                            if activeSchoolYear == schoolYear.name {
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
                        }.disabled(activeSchoolYear == schoolYear.name)
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
                EditSchoolYearsView(oldSchoolYear: schoolYear, activeSchoolYear: $activeSchoolYear)
            })
            .sheet(isPresented: $showAddSchoolYear) {
                AddSchoolYearsView()
            }
            Spacer()
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


