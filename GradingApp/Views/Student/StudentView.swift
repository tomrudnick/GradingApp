//
//  StudentView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct StudentView: View {
    
    @ObservedObject var student: Student
    
    @State var showAddGradeSheet = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack{
                    Text("Gesamt: ")
                        .font(.title)
                        .padding()
                    Spacer()
                    Button(action: {}, label: {
                        VStack {
                            Text(student.getLowerSchoolRoundedGradeAverage()).font(.title)
                            Text(student.getLowerSchoolGradeAverage())
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
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
                            VStack {
                                Text(student.getLowerSchoolRoundedGradeAverage(.oral)).font(.title)
                                Text(student.getLowerSchoolGradeAverage(.oral))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
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
                            VStack {
                                Text(student.getLowerSchoolRoundedGradeAverage(.written)).font(.title)
                                Text(student.getLowerSchoolGradeAverage(.written))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }).padding()
                }
                Spacer()
            }
            .padding(.trailing, 80)
        }
        .padding()
        .padding(.trailing, 5.0)
        .navigationTitle(Text("\(student.firstName) \(student.lastName)"))
        .navigationBarItems(trailing: addGradeButton)
    }
    
    var addGradeButton: some View {
        Button(action: {
            showAddGradeSheet = true
        }, label: {
            Text("Add Grade")
        }).sheet(isPresented: $showAddGradeSheet, content: {
            AddSingleGradeView(student: student)
        })
    }
    
    
}



struct StudentView_Previews: PreviewProvider {
    static var previewStudent : Student {
        let student = Student(context: PersistenceController.preview.container.viewContext)
        student.firstName = "Marit"
        student.lastName = "Abken"
        return student
    }
    static var previews: some View {
        StudentView(student: previewStudent)
    }
}
