//
//  BottomsheetGradePickerView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 08.08.21.
//

import SwiftUI

struct BottomsheetGradePickerView: View {
    
    @Binding var showAddGradeSheet: Bool
    @Binding var currentGrade: String
    

    var geometry: GeometryProxy
    
    var body: some View {
        BottomSheetView(isOpen: $showAddGradeSheet,
                        maxHeight: geometry.size.height * 0.5) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                ForEach(Grade.lowerSchoolGrades, id: \.self) { grade in
                    Button(action: {
                        self.currentGrade = grade
                        self.showAddGradeSheet = false
                    }, label: {
                        Text(grade)
                            .foregroundColor(.white)
                            .font(.headline)
                            .frame(height: 40)
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    })
                    .padding(.all, 2.0)
                }
            })
        }
    }
}

/*struct BottomsheetGradePickerView_Previews: PreviewProvider {
    static var previews: some View {
        BottomsheetGradePickerView()
    }
}*/
