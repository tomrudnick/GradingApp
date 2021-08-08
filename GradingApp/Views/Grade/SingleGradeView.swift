//
//  SingleGradeView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 07.08.21.
//

import SwiftUI

struct SingleGradeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var student: Student
    
    @State private var gradeDate: Date
    @State private var selectedGradeType: Int
    @State private var currentGrade: String
    @State private var selectedGradeMultiplier: Int
    @State private var comment: String
    
    @State private var showAddGradeSheet = false
    
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
        self._currentGrade = State(initialValue: Grade.gradeValueToLowerSchool(value: Int(currentGrade)))
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
                        CancelButtonView(label: "Abbrechen")
                        Spacer()
                        Button(action: {
                            save()
                        }, label: {
                            Text("Save")
                        })
                        .disabled(currentGrade == "-")
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
                    .font(.headline)
                Form {
                    
                    Section {
                        HStack {
                            DatePicker("Datum", selection: $gradeDate, displayedComponents: [.date])
                                .id(gradeDate) //Erzwingt den Datepicker einen rebuild des Views zu machen
                                .environment(\.locale, Locale.init(identifier: "de"))
                        }
                        Picker(selection: $selectedGradeType, label: Text(""), content: {
                            Text("Oral").tag(0)
                            Text("Written").tag(1)
                        }).pickerStyle(SegmentedPickerStyle())
                        HStack {
                            Text("Grade")
                            Spacer()
                            Button(action: {
                                showAddGradeSheet.toggle()
                            }, label: {
                                Text(currentGrade)
                                    .padding()
                                    .frame(height: 25)
                                    .background(Color(#colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)))
                                    .cornerRadius(5.0)
                            })
                        }
                    }
                    Section(header: Text("Grade Multiplier") ) {
                        Picker(selection: $selectedGradeMultiplier, label: Text(""), content: {
                            Text(String(Grade.gradeMultiplier[0])).tag(0)
                            Text(String(Grade.gradeMultiplier[1])).tag(1)
                            Text(String(Grade.gradeMultiplier[2])).tag(2)
                            Text(String(Grade.gradeMultiplier[3])).tag(3)
                        }).pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Section(header: Text("Comment")) {
                        TextField("Comment...", text: $comment)
                    }
                }
            }
            .navigationBarItems(trailing: Button(action: save, label: { Text("Speichern") }))
          
            BottomsheetGradePickerView(showAddGradeSheet: $showAddGradeSheet, currentGrade: $currentGrade, geometry: geometry)
        }
    }
    
    func save() {
        let multiplier = Grade.gradeMultiplier[selectedGradeMultiplier]
        let type = selectedGradeType == 0 ? GradeType.oral : GradeType.written
        let points = Grade.lowerSchoolGradesTranslate[currentGrade]!
        saveHandler(points, type, multiplier, gradeDate, comment)
        presentationMode.wrappedValue.dismiss()
    }
    
    
}

//struct SingleGradeView_Previews: PreviewProvider {
//    static var previews: some View {
//        SingleGradeView()
//    }
//}
