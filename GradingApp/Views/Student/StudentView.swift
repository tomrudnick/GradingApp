//
//  StudentView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI
import SwiftUICharts

struct StudentView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var student: Student
    @StateObject var sendEmailViewModel = SendSingleEmailViewModel()
    
    @State var showSendEmailSheet = false
    @State var showAddGradeSheet = false
    @State private var action: Int? = 0
    var columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 30) {
                
                GradeGridViewDisplay(title: "Gesamt     ", gradeRounded: student.getRoundedGradeAverage(half: halfYear), grade: student.getGradeAverage(half: halfYear), color: Grade.getColor(points: student.totalGradeAverage(half: halfYear)))
                
                
                NavigationLink(destination: GradeDetailView(student: student, gradeType: .oral)) {
                    GradeGridViewDisplay(title: "Mündlich   ", gradeRounded: student.getRoundedGradeAverage(.oral, half: halfYear), grade: student.getGradeAverage(.oral, half: halfYear), color: Grade.getColor(points: student.gradeAverage(type: .oral, half: halfYear)))
                }
                
                NavigationLink(destination: GradeDetailView(student: student, gradeType: .written)) {
                    GradeGridViewDisplay(title: "Schriftlich", gradeRounded: student.getRoundedGradeAverage(.written, half: halfYear), grade: student.getGradeAverage(.written, half: halfYear), color: Grade.getColor(points: student.gradeAverage(type: .written, half: halfYear)))
                }
                
                Button {
                    self.sendEmailViewModel.fetchData(student: student, half: halfYear)
                    self.showSendEmailSheet.toggle()
                } label: {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Send Email")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                }.disabled(!sendEmailViewModel.emailAccountViewModel.emailAccountUsed)
                
            }
            CardView {
                ChartLabel("Mündlich", type: .subTitle)
                LineChart()
            }
            .data(student.gradesArr.filter({$0.type == .oral && $0.half == halfYear}).map({Double(Int($0.value))}))
            .chartStyle(ChartStyle(backgroundColor: .white, foregroundColor: [ColorGradient(.purple, .blue)]))
            .padding()
            //LineChartView(data: student.gradesArr.filter({$0.type == .oral}).map({Double(Int($0.value))}), title: "Mündlich", form: ChartForm.extraLarge)
            Spacer()
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
        .sheet(isPresented: $showSendEmailSheet, content: {
            SendEmailsView(title: "\(student.firstName) \(student.lastName)", emailViewModel: sendEmailViewModel)
        })
        .sheet(isPresented: $showAddGradeSheet, content: {
            AddSingleGradeView(student: student)
                .environment(\.currentHalfYear, halfYear)
                .environment(\.managedObjectContext, viewContext)
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

struct GradeGridViewDisplay: View {
    var title: String
    var gradeRounded: String
    var grade: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
            Text(gradeRounded)
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(color)
            Text("(\(grade))")
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(color)
                
        }
        .padding()
        .background(Color.blue)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
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
