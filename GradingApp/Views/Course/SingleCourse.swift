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
    
    @Binding var courseName: String
    
    let viewTitle: String
    let saveHandler: () -> ()
    
    init(viewTitle: String, courseName: Binding<String>, saveHandler : @escaping () -> ()) {
        self.viewTitle = viewTitle
        self._courseName = courseName
        self.saveHandler = saveHandler
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
        saveHandler()
        //Course.addCourse(courseName: courseName, context: viewContext)
        presentationMode.wrappedValue.dismiss()
    }
}

struct SingleCourse_Previews: PreviewProvider {
    @State static var kursName = ""
    static var previews: some View {
        SingleCourse(viewTitle: "Neuer Kurs", courseName: $kursName) { }
    }
}
