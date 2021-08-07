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
    @State var showAddGradeSheeet = false
    
    var addGradeButton: some View {
        Button(action: {
            showAddGradeSheeet = true
        }, label: {
            Text("Add Grade")
        }).sheet(isPresented: $showAddGradeSheeet, content: {
            AddSingleGradeView(student: student)
        })
    }
    
    var body: some View {
        VStack {
            Text("Data of Student")
            Button(action: {
                    showAddGradeSheet.toggle()
                    print("button pressed")
                
            }, label: {
                Text("Button")
            })
            GeometryReader { geometry in
                BottomSheetView(isOpen: $showAddGradeSheet,
                                maxHeight: geometry.size.height * 0.5) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                        ForEach(Grade.lowerSchoolGrades, id: \.self) { grade in
                            Button(action: {
                                printGrade(grade: grade)
                            }, label: {
                                Text(grade)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .frame(height: 40)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                            })
                            .padding(.all, 2.0)
                        }
                    })
                }
            }.edgesIgnoringSafeArea(.all)
        }.navigationTitle(Text(student.firstName))
        .navigationBarItems(trailing: addGradeButton)
    }
    
    private func printGrade(grade: String) {
        print(grade)
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
