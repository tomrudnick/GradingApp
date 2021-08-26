//
//  GradeAtDatesSelectionView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.08.21.
//

import SwiftUI

struct GradeAtDatesSelectionView: View {
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
            GradeAtDatesView(course: course, gradeType: gradeType)
            /*List {
                ForEach(getGradesPerDate(for: gradeType).sorted(by: {$0.key < $1.key }), id: \.key) { key, value in
                    NavigationLink(destination: StudentGradesAtDate(course: course, date: key, gradeType: gradeType)) {
                        HStack {
                            Text(key.dateAsString())
                            Spacer()
                            Text(String(value))
                        }
                    }
                }
            }*/
        }
    }
}


/*struct GradeAtDatesView_Previews: PreviewProvider {
    static var previews: some View {
        GradeAtDatesView()
    }
}*/
