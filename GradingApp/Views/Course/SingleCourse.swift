//
//  SingleCourse.swift
//  GradingApp
//
//  Created by Tom Rudnick on 09.08.21.
//

import SwiftUI

struct SingleCourse: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State var courseName: String
    
    let viewTitle: String
    let saveHandler: (_ name: String) -> ()
    
    init(viewTitle: String, courseName: String = "", saveHandler : @escaping (_ name: String) -> ()) {
        self.viewTitle = viewTitle
        self.saveHandler = saveHandler
        self._courseName = State(initialValue: courseName)
    }
    var body: some View {
        VStack {
            VStack {
                HStack{
                    Text(viewTitle).font(.headline)
                Spacer()
                    CancelButtonView(label: "Abbrechen")
                }
            }
            .padding()
            CustomTextfieldView(label: "Kursname", input: $courseName)
            CustomButtonView(label: "Speichern", action: saveButtonPressed, buttonColor: .accentColor)
            .disabled(courseName.isEmpty)
            Spacer()
        }
    }
        
    func saveButtonPressed() {
        saveHandler(courseName)
        presentationMode.wrappedValue.dismiss()
    }
}

struct SingleCourse_Previews: PreviewProvider {
    @State static var kursName = ""
    static var previews: some View {
        SingleCourse(viewTitle: "Neuer Kurs") { _ in }
    }
}
