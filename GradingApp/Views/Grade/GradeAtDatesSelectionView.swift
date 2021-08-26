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
        }
    }
}


/*struct GradeAtDatesView_Previews: PreviewProvider {
    static var previews: some View {
        GradeAtDatesView()
    }
}*/
