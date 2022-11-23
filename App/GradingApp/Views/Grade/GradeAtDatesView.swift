//
//  GradeAtDatesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import SwiftUI


struct GradeAtDatesView: View {
    
    @EnvironmentObject var appSettings: AppSettings
    // An alternative to the fetch Requst would be to make the course Observable
    // This however would complicate the logic of the getGradesPerDate function.
    // Furthermore the view would not update automatically if a new grades would be added
    @FetchRequest(fetchRequest: Grade.fetchRequest()) private var grades: FetchedResults<Grade>
    @FetchRequest(fetchRequest: Exam.fetchRequest()) private var exams: FetchedResults<Exam>
    @StateObject var sendGradeEmailViewModel = SendMultipileEmailsSelectedGradeViewModel()
   
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @State var showEmailSheet = false
    @State var exam: Exam?
    
    
    
    let gradeType: GradeType
    let course: Course

    init(course: Course, gradeType: GradeType, half: HalfType) {
        self.course = course
        self.gradeType = gradeType
        let request = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@ AND half = %d AND student.hidden = NO", gradeType == .oral ? 0 : 1, course, half == .firstHalf ? 0 : 1))
        
        self._grades = FetchRequest(fetchRequest: request)
        
        let examRequest = Exam.fetch(NSPredicate(format: "student.course = %@ AND half = %d", course, half == .firstHalf ? 0 : 1))
        self._exams = FetchRequest(fetchRequest: examRequest)
        
    }
    
    
    var body: some View {
        List {
            ForEach(Grade.getGradesPerDatePerMonth(grades: grades).sorted(by: {Calendar.current.date(from: $0.key)! < Calendar.current.date(from: $1.key)!}), id: \.key) { key, value in
                
                Section("\(Calendar.current.date(from: key)!.asString(format: "MMM yyyy"))") {
                    ForEach(value.sorted(by: {$0.key < $1.key }), id: \.key) { key, value in
                        NavigationLink(value: Route.GradeAtDates(course, value)) {
                            HStack {
                                Text(key.asString(format: "dd MMM HH:mm"))
                                Spacer()
                                Text(Grade.getComment(studentGrades: value) ?? "ver. Kommentare")
                                Spacer()
                                
                                if value.count == 1 {
                          
                                    Image(systemName: "person")
                                    let student = value.first!.student
                                    if let firstLetter = student.lastName.first {
                                        Text("\(student.firstName) \(String(firstLetter))")
                                    } else {
                                        Text("\(student.firstName)")
                                    }
                                    
                                } else {
                                    Image(systemName: "person.3.sequence")
                                    Text("\(value.count) / \(course.studentsCount)")
                                }
                                Image(systemName: "sum")
                                GradeText(ageGroup: self.course.ageGroup, grade: GradeStudent<Grade>.getGradeAverage(studentGrades: value))
                                    .frame(minWidth: 40)
                                    .padding(5.0)
                                    .background(.gray)
                                    .cornerRadius(5.0)
                            }
                        }
                        .contextMenu(menuItems: {
                            Button(action: {
                                sendGradeEmailViewModel.fetchData(half: halfYear, date: key, gradeStudents: value)
                                self.showEmailSheet = true
                            }, label: {
                                Text("Ausgewählte Noten als E-Mail verschicken")
                            }).disabled(!sendGradeEmailViewModel.emailAccountViewModel.emailAccountUsed)
                        })
                    }
                }.headerProminence(.increased)
            }
            Section("Exams") {
                ForEach(course.exams.sorted { $0.date < $1.date }, id: \.name) { exam in
                    Button {
                        self.exam = exam
                    } label: {
                        HStack {
                            Text(exam.name)
                            Spacer()
                        }
                    }
                }
            }
            
        }.sheet(isPresented: $showEmailSheet, content: {
            SendEmailsView(title: course.title, emailViewModel: sendGradeEmailViewModel)
        })
        .fullScreenCover(item: $exam) { exam in
            EditExamView(exam: exam)
                .environmentObject(appSettings)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}


/*struct GradeAtDatesView_Previews: PreviewProvider {
    static var previews: some View {
        GradeAtDatesView()
    }
}*/
