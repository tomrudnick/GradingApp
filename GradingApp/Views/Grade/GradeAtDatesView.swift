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
