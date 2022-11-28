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
    @StateObject var sendExamEmailViewModel = SendMultipleEmailsExamViewModel()
   
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @State var showEmailSheet = false
    @State var showExamEmailSheet = false
    @State var exam: Exam?
    
    
    
    let gradeType: GradeType
    let course: Course

    init(course: Course, gradeType: GradeType, half: HalfType) {
        self.course = course
        self.gradeType = gradeType
        let request = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@ AND half = %d AND student.hidden = NO", gradeType == .oral ? 0 : 1, course, half == .firstHalf ? 0 : 1))
        
        self._grades = FetchRequest(fetchRequest: request)
        
        let examRequest = Exam.fetch(NSPredicate(format: "course = %@ AND half = %d", course, half == .firstHalf ? 0 : 1))
        self._exams = FetchRequest(fetchRequest: examRequest)
        
    }
    
    
    var body: some View {
        List {
            if gradeType == .oral {
                ForEach(Grade.getGradesPerDatePerMonth(grades: grades).sorted(by: {Calendar.current.date(from: $0.key)! < Calendar.current.date(from: $1.key)!}), id: \.key) { key, value in
                    Section("\(Calendar.current.date(from: key)!.asString(format: "MMM yyyy"))") {
                        ForEach(value.sorted(by: {$0.key < $1.key }), id: \.key) { key, value in
                            NavigationLink(value: Route.GradeAtDates(course, value)) {
                                getStandardGradeView(key: key, value: value)
                            }
                        }
                    }.headerProminence(.increased)
                }
            } else {
                ForEach(Grade.getGradesPerDate(grades: grades, exams: exams).sorted(by: { $0.key < $1.key }), id: \.key) { date, grade in
                    switch grade {
                    case .normal(let grades):
                        NavigationLink(value: Route.GradeAtDates(course, grades)) {
                            getStandardGradeView(key: date, value: grades)
                        }
                    case .exam(let exam):
                        Button {
                            self.exam = exam
                        } label: {
                            let averageGradePair = exam.getAverage2()
                            HStack {
                                GradesAtDatesCellView(participantCount: exam.participationCount(),
                                                      studentCount: course.students.count,
                                                      onlyStudent: exam.participations.first { $0.participated }?.student,
                                                      date: date,
                                                      averageGrade: String(format: "%.1f", averageGradePair.0),
                                                      color: averageGradePair.1,
                                                      ageGroup: course.ageGroup,
                                                      comment: exam.name)
                                Image(systemName: "chevron.forward")
                                    .foregroundColor(.secondary)
                            }
                            
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                sendExamEmailViewModel.fetchData(half: halfYear, exam: exam)
                                self.showExamEmailSheet.toggle()
                            } label: {
                                Text("Ausgewählte Noten per Email verschicken")
                            }.disabled(!sendExamEmailViewModel.emailAccountViewModel.emailAccountUsed)
                        }
                    }
                }
            }
        }.sheet(isPresented: $showEmailSheet, content: {
            SendEmailsView(title: course.title, emailViewModel: sendGradeEmailViewModel)
        })
        .sheet(isPresented: $showExamEmailSheet, content: {
            SendEmailsView(title: course.title, emailViewModel: sendExamEmailViewModel)
        })
        .fullScreenCover(item: $exam) { exam in
            EditExamView(exam: exam, course: course)
                .environmentObject(appSettings)
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
    func getStandardGradeView(key: Date, value: [GradeStudent<Grade>]) -> some View {
        let averageGrade = GradeStudent<Grade>.getGradeAverage(studentGrades: value)
        return GradesAtDatesCellView(participantCount: value.count,
                              studentCount: course.students.count,
                              onlyStudent: value.first?.student,
                              date: key,
                              averageGrade: getGradeText(grade: averageGrade),
                              color: Grade.getColor(points: averageGrade),
                              ageGroup: course.ageGroup,
                              comment: Grade.getComment(studentGrades: value))
        .contextMenu(menuItems: {
            Button(action: {
                sendGradeEmailViewModel.fetchData(half: halfYear, date: key, gradeStudents: value)
                self.showEmailSheet = true
            }, label: {
                Text("Ausgewählte Noten per E-Mail verschicken")
            }).disabled(!sendGradeEmailViewModel.emailAccountViewModel.emailAccountUsed)
        })
    }
    
    func getGradeText(grade: Double) -> String {
        if course.ageGroup == .lower {
            return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: grade))
        } else {
            return String(format: "%.1f", grade)
        }
    }
}


/*struct GradeAtDatesView_Previews: PreviewProvider {
    static var previews: some View {
        GradeAtDatesView()
    }
}*/
