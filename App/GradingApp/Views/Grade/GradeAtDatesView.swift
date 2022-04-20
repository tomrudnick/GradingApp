//
//  GradeAtDatesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import SwiftUI


struct GradeAtDatesView: View {

    // An alternative to the fetch Requst would be to make the course Observable
    // This however would complicate the logic of the getGradesPerDate function.
    // Furthermore the view would not update automatically if a new grades would be added
    @FetchRequest(fetchRequest: Grade.fetchRequest()) private var grades: FetchedResults<Grade>
    @StateObject var sendGradeEmailViewModel = SendMultipileEmailsSelectedGradeViewModel()
   
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @State var showEmailSheet = false
    @State var selectedStudentGradeNavLink: Date? = nil
    
    let gradeType: GradeType
    let course: Course

    init(course: Course, gradeType: GradeType, half: HalfType) {
        self.course = course
        self.gradeType = gradeType
        let request = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@ AND half = %d AND student.hidden = NO", gradeType == .oral ? 0 : 1, course, half == .firstHalf ? 0 : 1))
        
        self._grades = FetchRequest(fetchRequest: request)
    }
    
    
    var body: some View {
        List {
            ForEach(Grade.getGradesPerDate(grades: grades).sorted(by: {$0.key < $1.key }), id: \.key) { key, value in
                NavigationLink(destination: GradeAtDatesEditView(course: course, studentGrades: value), tag: key, selection: $selectedStudentGradeNavLink) {
                    HStack {
                        Text(key.asString(format: "dd MMM HH:mm"))
                        Spacer()
                        Text(Grade.getComment(studentGrades: value) ?? "ver. Kommentare")
                        Spacer()
                        if value.count == 1 {
                            let student = value.first!.student
                            if let firstLetter = student.lastName.first {
                                Text("\(student.firstName) \(String(firstLetter))")
                            } else {
                                Text("\(student.firstName)")
                            }
                            
                        } else {
                            Text("\(value.count) / \(course.studentsCount)")
                        }
                    }
                }
                .onChange(of: selectedStudentGradeNavLink, perform: { value in
                    if value == nil {
                        viewContext.saveCustom()
                    }
                })
                .contextMenu(menuItems: {
                    Button(action: {
                        sendGradeEmailViewModel.fetchData(half: halfYear, date: key, gradeStudents: value)
                        self.showEmailSheet = true
                    }, label: {
                        Text("Ausgewählte Noten als E-Mail verschicken")
                    }).disabled(!sendGradeEmailViewModel.emailAccountViewModel.emailAccountUsed)
                })
            }
        }.sheet(isPresented: $showEmailSheet, content: {
            SendEmailsView(title: course.title, emailViewModel: sendGradeEmailViewModel)
        })
    }
}


/*struct GradeAtDatesView_Previews: PreviewProvider {
    static var previews: some View {
        GradeAtDatesView()
    }
}*/
