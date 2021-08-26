//
//  MoreActionsView.swift
//  GradingApp
//
//  Created by Tom Rudnick on 26.08.21.
//

import SwiftUI
import UniformTypeIdentifiers

struct MoreActionsView: View {
    
    @State private var showingExporter = false
    @Environment(\.managedObjectContext) private var viewContext
     
    var body: some View {
        Form {
            Section {
                Button {
                    self.showingExporter = true
                } label: {
                    Text("Backup")
                }
            }
        }.fileExporter(isPresented: $showingExporter, documents: getDocuments(), contentType: .commaSeparatedText) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getDocuments() -> [CSVFile] {
        let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
        var files: [CSVFile] = []
        for course in fetchedCourses {
            let oralRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 0, course))
            let oralGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: oralRequest)
            files.append(CSVFile(course: course, grades: oralGrades, fileName: "\(course.name)_muendlich"))
            let writtenRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 1, course))
            let writtenGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: writtenRequest)
            files.append(CSVFile(course: course, grades: writtenGrades, fileName: "\(course.name)_schriftlich"))
        }
        return files
    }
    
}


struct MoreActionsView_Previews: PreviewProvider {
    static var previews: some View {
        MoreActionsView()
    }
}