//
//  SubjectListView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.03.22.
//

import SwiftUI
import CoreData

struct SubjectListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(fetchRequest: Subject.fetchAll(), animation: .default)
    private var subjects: FetchedResults<Subject>
    
    @Binding var subject: String
    @State var showAddSheet = false
    
    var body: some View {
        List {
            ForEach(subjects, id: \.self) { subject in
                Button {
                    self.subject = subject.name
                    dismiss()
                } label: {
                    HStack {
                        Text("\(subject.name)")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.foregroundColor(Color.primary)
                    
                }.contextMenu {
                    if #available(macCatalyst 15.0, *) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewContext.delete(subject)
                                viewContext.saveCustom()
                            }
                        } label: {
                            Text("Löschen")
                        }
                    } else {
                        Button {
                            viewContext.delete(subject)
                            viewContext.saveCustom()
                        } label: {
                            Text("Löschen")
                        }
                    }

                }
            }.onDelete(perform: removeSubject)
        }.toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    self.showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }.sheet(isPresented: $showAddSheet) {
            AddSubjectView()
        }.navigationTitle(Text("Fach auswählen"))
    }
    
    func removeSubject(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(subjects[index])
        }
        viewContext.saveCustom()
    }
}

struct AddSubjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @State var subjectName = ""
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                }.padding(.leading)
                Text("Fach hinzufügen").font(.title).frame(maxWidth: .infinity, alignment: .center).padding()
                Spacer()
            }
            
            TextField("Z.B. Mathe", text: $subjectName).padding()
            CustomButtonView(label: "Hinzufügen", action: {
                Subject.addSubject(name: subjectName, context: viewContext)
                dismiss()
            }, buttonColor: .accentColor).disabled(subjectName.isEmpty)
            Spacer()
        }
    }
}
