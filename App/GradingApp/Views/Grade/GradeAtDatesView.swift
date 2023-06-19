//
//  GradeAtDatesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import SwiftUI


struct GradeAtDatesView: View {
    
    enum AlertType {
        case countMismatch
        case export
    }
    
    @EnvironmentObject var appSettings: AppSettings
    // An alternative to the fetch Requst would be to make the course Observable
    // This however would complicate the logic of the getGradesPerDate function.
    // Furthermore the view would not update automatically if a new grades would be added
    @FetchRequest(fetchRequest: Grade.fetchRequest()) private var grades: FetchedResults<Grade>
    @FetchRequest(fetchRequest: Exam.fetchRequest()) private var exams: FetchedResults<Exam>
    @StateObject var sendGradeEmailViewModel = SendMultipileEmailsSelectedGradeViewModel()
    @StateObject var sendExamEmailViewModel = SendMultipleEmailsExamViewModel()
    @StateObject var sendExamEmailAttachmentsViewModel = SendMultipleEmailsExamAttachmentViewModel()
   
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @State var showEmailSheet = false
    @State var showExamEmailSheet = false
    @State var importExamFiles = false
    @State var showExamAttachmentEmailSheet = false
    @State var exam: Exam?
    
    @State var showAlert = false
    @State var alertType: AlertType = .countMismatch
    @State var exportAlertText = ""
    
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
                ForEach(Grade.getGradesPerDate(grades: grades, exams: exams).sorted(by: { $0.key < $1.key }), id: \.key) { date, grades in
                    HStack {
                        getWrittenGradeView(date: date, writtenGrades: grades)
                    }
                }
            }
        }.sheet(isPresented: $showEmailSheet, content: {
            SendEmailsView(title: course.title, emailViewModel: sendGradeEmailViewModel)
        })
        .sheet(isPresented: $showExamEmailSheet, content: {
            SendEmailsView(title: course.title, emailViewModel: sendExamEmailViewModel)
        })
        .sheet(isPresented: $showExamAttachmentEmailSheet, content: {
            SendEmailsView(title: "\(course.title) - Anhänge", emailViewModel: sendExamEmailAttachmentsViewModel)
        })
        .fullScreenCover(item: $exam) { exam in
            EditExamView(exam: exam, course: course)
                .environmentObject(appSettings)
                .environment(\.managedObjectContext, viewContext)
        }
        .fileImporter(isPresented: $importExamFiles, allowedContentTypes: [.pdf], allowsMultipleSelection: true) { result in
            guard let exam = sendExamEmailAttachmentsViewModel.exam else { return }
            do {
                let exportedExams =  try PDFFile.pdfFileExamImporter(exam: exam, result: result)
                sendExamEmailAttachmentsViewModel.fetchAttachments(exportedExams)
                self.showExamAttachmentEmailSheet.toggle()
            } catch ImportError.countMissmatch {
                self.alertType = .countMismatch
                self.showAlert.toggle()
            } catch ImportError.matchInsecurity(let possibleMissmatches, let exportedExams){
                exportAlertText = ""
                for missmatch in possibleMissmatches {
                    exportAlertText += "Student: \(missmatch.student.firstName) \(missmatch.student.lastName) FileName: \(missmatch.fileName) Score: \(missmatch.score)\n"
                }
                sendExamEmailAttachmentsViewModel.fetchAttachments(exportedExams)
                alertType = .export
                showAlert.toggle()
            } catch (let error) {
                print(error.localizedDescription)
            }
        }
        .alert("Achtung", isPresented: $showAlert, actions: {
            switch alertType {
            case .countMismatch: countMismatchAlertActions
            case .export : exportAlertActions
            }
        }, message: {
            switch alertType {
            case .export: Text(exportAlertText)
            case .countMismatch: Text("Schüler Anzahl und Anzahl Klassenarbeiten stimmt nicht überein")
            }
        })
    }
    
    var countMismatchAlertActions: some View {
        Button("Ok") { }
    }
    
    var exportAlertActions: some View {
        Group {
            Button("Fortfahren") { self.showExamAttachmentEmailSheet.toggle() }
            Button("Abbrechen") { }
        }
    }
    
    
    @ViewBuilder func getWrittenGradeView(date: Date, writtenGrades: Grade.WrittenGradeType) -> some View {
        switch writtenGrades {
        case .normal(let grades):
            NavigationLink(value: Route.GradeAtDates(course, grades)) {
                getStandardGradeView(key: date, value: grades)
            }
        case .exam(let exam):
            Button {
                self.exam = exam
            } label: {
                getExamGradeView(key: date, value: exam)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
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
    
    @ViewBuilder func getExamGradeView(key: Date, value: Exam) -> some View {
        let averageGradePair = value.getAverage2()
        HStack{
            GradesAtDatesCellView(participantCount: value.participationCount(),
                                  studentCount: course.students.count,
                                  onlyStudent: value.participations.first { $0.participated }?.student,
                                  date: key,
                                  averageGrade: String(format: "%.1f", averageGradePair.0),
                                  color: averageGradePair.1,
                                  ageGroup: course.ageGroup,
                                  comment: value.name)
            Image(systemName: "chevron.forward")
                .foregroundColor(.secondary)
        }
        .contextMenu {
            Button {
                sendExamEmailViewModel.fetchData(half: halfYear, exam: value)
                self.showExamEmailSheet.toggle()
            } label: {
                Text("Ausgewählte Noten per Email verschicken")
            }.disabled(!sendExamEmailViewModel.emailAccountViewModel.emailAccountUsed)
            Button {
                self.sendExamEmailAttachmentsViewModel.fetchData(half: halfYear, exam: value)
                self.importExamFiles.toggle()
            } label: {
                Text("Ausgewählte Noten per Email zusammen mit Klassenarbeit verschicken")
            }.disabled(!sendExamEmailViewModel.emailAccountViewModel.emailAccountUsed)
        }
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
