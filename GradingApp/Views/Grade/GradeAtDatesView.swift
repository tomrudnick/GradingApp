//
//  GradeAtDatesView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.08.21.
//

import SwiftUI

struct GradeAtDatesView: View {
    @State private var selectedGradeType: Int = 0
    private var gradeType : GradeType {
        selectedGradeType == 0 ? GradeType.oral : GradeType.written
    }
    
    @ObservedObject var course: Course
    
    
    var body: some View {
        VStack {
            Picker(selection: $selectedGradeType, label: Text("")) {
                Text("Oral").tag(0)
                Text("Written").tag(1)
            }.pickerStyle(SegmentedPickerStyle())
            List {
                ForEach(getGradesPerDate(for: gradeType).sorted(by: {$0.key < $1.key }), id: \.key) { key, value in
                    NavigationLink(destination: StudentGradesAtDate(course: course, date: key, gradeType: gradeType)) {
                        HStack {
                            Text(key.dateAsString())
                            Spacer()
                            Text(String(value))
                        }
                    }
                }
            }
        }
    }
    
    func getGradesPerDate(for gradeType: GradeType) -> [Date : Int] {
        var allDates: [Date : Int] = [:]
        for student in course.students {
            for grade in student.grades.filter({$0.type == gradeType}) {
                if let dateCount = allDates[grade.date!] {
                    allDates[grade.date!] = dateCount + 1
                } else {
                    allDates[grade.date!] = 1
                }
            }
        }
        return allDates
    }
    
}

struct StudentGradesAtDate : View{
    
    @ObservedObject var course: Course
    var date: Date
    var gradeType: GradeType
    
    var body: some View {
        List {
            ForEach(getGradesAtOneDate(for: date, gradeType: gradeType)) { studentGrade in
                HStack {
                    Text("\(studentGrade.student.firstName) \(studentGrade.student.lastName)")
                    Spacer()
                    Text(Grade.convertGradePointsToGrades(value: Int(studentGrade.grade?.value ?? -1)))
                        .foregroundColor(Grade.getColor(points: Double(studentGrade.grade?.value ?? -1)))
                        .padding()
                        .frame(minWidth: 55)
                        .foregroundColor(.white)
                        .font(.headline)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                        
                }
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Edit")
            }
        })
        .navigationTitle(Text(date.dateAsString()))
        
    }
    
    func getGradesAtOneDate(for date: Date, gradeType: GradeType) -> [StudentGradesAtDate] {
        var studentGrades: [StudentGradesAtDate] = []
        for student in course.students {
            var appendedStudent: Bool = false
            for grade in student.grades.filter({$0.date == date && $0.type == gradeType}) {
                appendedStudent = true
                studentGrades.append(StudentGradesAtDate(student: student, grade: grade))
            }
            if !appendedStudent {
                studentGrades.append(StudentGradesAtDate(student: student, grade: nil))
            }
        }
        
        return studentGrades.sorted(by: {$0.student.firstName < $1.student.firstName}).sorted(by: {$0.student.lastName < $1.student.lastName})
    }
    
    struct StudentGradesAtDate : Identifiable {
        let id: UUID = UUID()
        var student: Student
        var grade: Grade?
    }
}

extension Date {
    func dateAsString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: self)
    }
}

/*struct GradeAtDatesView_Previews: PreviewProvider {
    static var previews: some View {
        GradeAtDatesView()
    }
}*/
