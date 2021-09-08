//
//  BottomsheetGradePickerView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 08.08.21.
//

import SwiftUI

struct BottomSheetMultipleGradesPicker: View {
    
    @Binding var showAddGradeSheet: Bool
    @Binding var selectedStudent: Student?
    @ObservedObject var course : Course
    @ObservedObject var viewModel: GradePickerViewModel
    

    var geometry: GeometryProxy
    var scrollProxy: ScrollViewProxy
    let buttonHandler: (_ grade: Int) -> ()
    
    var body: some View {
        BottomSheetView(isOpen: $showAddGradeSheet,
                        maxHeight: geometry.size.height * 0.5) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], content: {
                ForEach(viewModel.pickerValues, id: \.self) { grade in
                    Button(action: {
                        buttonHandler(viewModel.translateToInt(grade))
                        scrollToNext()
                    }, label: {
                        BottomSheetViewButtonLabel(labelView: Text(grade))
                    })
                    .padding(.all, 2.0)
                }
                Button {
                    buttonHandler(-1)
                } label: {
                    BottomSheetViewButtonLabel(labelView: Text("-"))
                }

                Button {
                    selectedStudent = course.previousStudent(before: selectedStudent!)
                    scrollToNext()
                } label: {
                    BottomSheetViewButtonLabel(labelView: Image(systemName: "arrow.up"))
                }
                
                Button {
                    selectedStudent = course.nextStudent(after: selectedStudent!)
                    scrollToNext()
                } label: {
                    BottomSheetViewButtonLabel(labelView: Image(systemName: "arrow.down"))
                }
                //A dismiss button for the mac os version is included in order to easier dismiss the sheet
                #if targetEnvironment(macCatalyst)
                Button {
                    self.showAddGradeSheet = false
                } label: {
                    BottomSheetViewButtonLabel(labelView: Image(systemName: "xmark.square"))
                }
                #endif
            })
        }.onChange(of: showAddGradeSheet, perform: { newValue in
            if newValue == false {
                selectedStudent = nil
            }
        })
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func scrollToNext() {
        if selectedStudent == nil {
            self.showAddGradeSheet = false
        } else {
            scrollProxy.scrollTo(selectedStudent?.id, anchor: .top)
        }
    }
}

/*struct BottomsheetGradePickerView_Previews: PreviewProvider {
    static var previews: some View {
        BottomsheetGradePickerView()
    }
}*/
