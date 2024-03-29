//
//  SingleGradeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//

import SwiftUI

struct SingleGradeView: View {
    
    @StateObject var viewModel = GradePickerViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var student: Student
    
    @State private var gradeDate: Date
    @State private var selectedGradeType: Int
    @State private var currentGrade: Int
    @State private var selectedGradeMultiplier: Int
    @State private var comment: String
    @State private var showAddGradeSheet = false
    
    #if !targetEnvironment(macCatalyst)
    @FocusState private var focusTextField: Bool
    #endif
    
    private let showSaveCancelButtons: Bool
    private let saveHandler: (_ points: Int, _ type: GradeType, _ multiplier: Double, _ date: Date, _ comment: String) -> ()
    
    init(student: Student,
         gradeDate: Date = Date(),
         selectedGradeType: GradeType = .oral,
         currentGrade: Int32 = -1,
         gradeMultiplier: Double = 1.0,
         comment: String  = "",
         showSaveCancelButtons: Bool = true,
         saveHandler: @escaping (_ points: Int, _ type: GradeType, _ multiplier: Double, _ date: Date, _ comment: String) -> ()
         ) {
        
       
        self.student = student
        self._gradeDate = State(initialValue: gradeDate)
        self._selectedGradeType = State(initialValue: selectedGradeType == .oral ? 0 : 1)
        self._currentGrade = State(initialValue: Int(currentGrade))
        let selectedGradeMultiplier = Grade.gradeMultiplier.firstIndex(where: { $0 == gradeMultiplier })!
        self._selectedGradeMultiplier = State(initialValue: selectedGradeMultiplier)
        self._comment = State(initialValue: comment)
        self.saveHandler = saveHandler
        self.showSaveCancelButtons = showSaveCancelButtons
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if showSaveCancelButtons {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Text("Abbrechen")
                        }

                        Spacer()
                        Button(action: {
                            save()
                        }, label: {
                            Text("Save")
                        })
                        .disabled(currentGrade == -1)
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    VStack{
                    Text("Neue Note")
                        .font(.title)
                    }
                    .padding(.top)
                }
                Text("\(student.firstName) \(student.lastName)")
                    .font(.title)
                    .padding(.top)
                Form {
                    
                    Section {
                        HStack {
                            DatePicker("Datum", selection: $gradeDate, displayedComponents: [.date])
                                .id(gradeDate) //Erzwingt den Datepicker einen rebuild des Views zu machen
                                .environment(\.locale, Locale.init(identifier: "de"))
                        }
                        Picker(selection: $selectedGradeType.animation(), label: Text(""), content: {
                            Text("Mündlich").tag(0)
                            Text("Schriftlich").tag(1)
                        }).pickerStyle(SegmentedPickerStyle())
                        HStack {
                            Text("Note")
                            Spacer()
                            Button(action: {
                                showAddGradeSheet.toggle()
                            }, label: {
                                Text(viewModel.translateToString(currentGrade))
                                    .padding()
                                    .frame(height: 25)
                                    .background(Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
                                    .cornerRadius(5.0)
                            })
                        }
                    }
                    if selectedGradeType == 0 {
                        Section(header: Text("Gewichtung") ) {
                            Picker(selection: $selectedGradeMultiplier, label: Text(""), content: {
                                ForEach(0..<Grade.gradeMultiplier.count, id: \.self) {index in
                                    Text(String(Grade.gradeMultiplier[index])).tag(index)
                                }
                            }).pickerStyle(SegmentedPickerStyle())
                        }
                        
                    }
                   
                    Section(header: Text("Kommentar")) {
                        TextField(
                            "LZK",
                            text: $comment
                        )
                        #if !targetEnvironment(macCatalyst)
                        .focused($focusTextField)
                        .onChange(of: focusTextField) { value in
                            if value {
                                showAddGradeSheet = false
                            }
                        }
                        #endif
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: save, label: { Text("Speichern") }).disabled(currentGrade == -1))
            BottomSheetSingleGradePicker(showAddGradeSheet: $showAddGradeSheet, viewModel: viewModel, geometry: geometry) { grade in
                currentGrade = grade
            }
            #if !targetEnvironment(macCatalyst)
            .onChange(of: showAddGradeSheet) { value in
                if value {
                    focusTextField = false
                }
            }
            #endif
        }
        .onAppear {
            viewModel.setup(courseType: student.course!.ageGroup, options: .normal)
        }
    }
    
    func save() {
        var multiplier = Grade.gradeMultiplier[selectedGradeMultiplier]
        let type = selectedGradeType == 0 ? GradeType.oral : GradeType.written
        if type == .written {
            multiplier = 1.0
        }
        saveHandler(currentGrade, type, multiplier, gradeDate, comment)
        dismiss()
    }
    
    
}

//struct SingleGradeView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleGradeView()
//    }
//}
