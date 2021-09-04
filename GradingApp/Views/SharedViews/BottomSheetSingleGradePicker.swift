//
//  BottomSheetSingleGradePicker.swift
//  GradingApp
//
//  Created by Tom Rudnick on 04.09.21.
//

import SwiftUI

struct BottomSheetSingleGradePicker: View {
    
    @Binding var showAddGradeSheet: Bool
    @ObservedObject var viewModel: GradePickerViewModel
    

    var geometry: GeometryProxy
    let buttonHandler: (_ grade: Int) -> ()
    
    var body: some View {
        BottomSheetView(isOpen: $showAddGradeSheet,
                        maxHeight: geometry.size.height * 0.5) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                ForEach(viewModel.pickerValues, id: \.self) { grade in
                    Button(action: {
                        buttonHandler(viewModel.translateToInt(grade))
                        self.showAddGradeSheet = false
                    }, label: {
                        BottomSheetViewButtonLabel(labelView: Text(grade))
                    })
                    .padding(.all, 2.0)
                }
                Button {
                    buttonHandler(-1)
                    self.showAddGradeSheet = false
                } label: {
                    BottomSheetViewButtonLabel(labelView: Text("-"))
                }
            })
        }.edgesIgnoringSafeArea(.bottom)
    }
}
