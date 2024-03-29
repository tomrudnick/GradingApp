//
//  SchoolYearsView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 07.09.22.
//

import SwiftUI

struct SchoolYearsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: SchoolYear.fetchAll(), animation: .default)
    private var schoolYear: FetchedResults<SchoolYear>
        
    @State private var selectedSchoolYear : SchoolYear? = nil
    @State private var showAddSchoolYear = false

    
    
    var body: some View {
        VStack{
            List {
                ForEach(schoolYear, id: \.self) { schoolYear in
                    Button {
                        appSettings.activeSchoolYearName = schoolYear.name
                    } label: {
                        HStack {
                            Text("Schuljahr \(schoolYear.name)")
                            
                            Spacer()
                            if appSettings.activeSchoolYearName == schoolYear.name {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .contextMenu { //right click menu for mac os catalyst app
                        getSwipeContextMenu(schoolYear: schoolYear)
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        getSwipeContextMenu(schoolYear: schoolYear)
                    }
                    
                }
            }
            .onAppear {
                appSettings.mergeDuplicatedSchoolYears()
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    addButton
                }
            })
            .sheet(item: $selectedSchoolYear, content: { schoolYear in
                EditSchoolYearsView(oldSchoolYear: schoolYear)
                    .environmentObject(appSettings)
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium])
            })
            .sheet(isPresented: $showAddSchoolYear) {
                AddSchoolYearsView()
                    .environment(\.managedObjectContext, viewContext)
                    .presentationDetents([.medium])
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
    
    //We use the same view for contextMenu and SwipeActions which is the reason for extracting it into this method
    @ViewBuilder //this is needed in order to omit return statements and to simplify that we return two buttons (It is just for convenience)
    func getSwipeContextMenu(schoolYear: SchoolYear) -> some View {
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
        }.disabled(appSettings.activeSchoolYear == schoolYear)
    }
}


//struct SchoolYearsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SchoolYearsView()
//    }
//}


