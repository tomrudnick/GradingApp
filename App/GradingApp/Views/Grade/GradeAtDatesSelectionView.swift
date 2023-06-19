//
//  GradeAtDatesSelectionView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 24.08.21.
//

import SwiftUI

struct GradeAtDatesSelectionView: View {
    @Environment(\.currentHalfYear) var halfYear
    @State private var selectedGradeType: GradeType = .oral
    @ObservedObject var course: Course

    var body: some View {
        VStack {
            Picker(selection: $selectedGradeType, label: Text("")) {
                Text("Mündliches").tag(GradeType.oral)
                Text("Schriftlich").tag(GradeType.written)
            }.pickerStyle(SegmentedPickerStyle())
            GradeAtDatesView(course: course, gradeType: selectedGradeType, half: halfYear)
        }
    }
}


/*struct GradeAtDatesView_Previews: PreviewProvider {
    static var previews: some View {
        GradeAtDatesView()
    }
}*/
