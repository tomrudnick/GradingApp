//
//  StudentView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct StudentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var student: Student
    
    @State var showAddGradeSheet = false
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack{
                        Text("Gesamt: ")
                            .font(.title)
                            .padding()
                        Spacer()
                        Button(action: {}, label: {
                                CostumGradeView(roundedGrade: student.getRoundedGradeAverage(),
                                                grade: student.getGradeAverage())
                        }).padding()
                    }
                    HStack{
                        Text("Mündlich: ")
                            .font(.title)
                            .padding()
                        Spacer()
                        NavigationLink(
                            destination: GradeDetailView(student: student, gradeType: .oral),
                            label: {
                                CostumGradeView(roundedGrade: student.getRoundedGradeAverage(.oral),
                                                grade: student.getGradeAverage(.oral))
                            }).padding()
                    }
                    HStack{
                        Text("Schriftlich: ")
                            .font(.title)
                            .padding()
                        Spacer()
                        NavigationLink(
                            destination: GradeDetailView(student: student, gradeType: .written),
                            label: {
                                CostumGradeView(roundedGrade: student.getRoundedGradeAverage(.written), grade: student.getGradeAverage(.written))
                            }).padding()
                    }
                    Spacer()
                }
                .frame(maxWidth: 235)
                Spacer()
            }
            
        }
        .padding()
        .padding(.trailing, 5.0)
        .navigationTitle(Text("\(student.firstName) \(student.lastName)"))
        .toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                addGradeButton
            }
        })
        .sheet(isPresented: $showAddGradeSheet, content: {
            AddSingleGradeView(student: student)
        })
        
        //.navigationBarItems(trailing: addGradeButton)
    }
    
    var addGradeButton: some View {
        Button(action: {
            showAddGradeSheet = true
        }, label: {
            Text("Neue Note")
        })
    }
    
    
}



struct StudentView_Previews: PreviewProvider {
    
    static let student = previewData(context: PersistenceController.preview.container.viewContext).first!.studentsArr.first!
    
    static var previews: some View {
        NavigationView{
            StudentView(student: student)
        }
    }
}
