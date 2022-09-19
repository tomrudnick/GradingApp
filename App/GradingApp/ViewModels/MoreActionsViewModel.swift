//
//  MoreActionsViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 27.08.21.
//

import Foundation
import CoreData
import Combine



class MoreActionsViewModel: ObservableObject {
    struct KeyValueConstants {
        static let dateFormat = "dd.MM.yyyy"
        static let firstHalf = "dateFirstHalf"
        static let secondHalf = "dateSecondHalf"
        static let selectedHalf = "selectedHalf"
    }
    

    static func getOneJsonFile(viewContext: NSManagedObjectContext) -> JSONFile {
        var jsonData: Data = Data()
        do {
            let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
            jsonData = try JSONEncoder().encode(fetchedCourses)
                
        } catch {
            print("Error fetching data from CoreData", error)
        }
        return JSONFile.generateJSONBackupFile(jsonData: String(data: jsonData, encoding: .utf8)!)
    }
    
    static func getSingleCSVFiles(viewContext: NSManagedObjectContext) -> [CSVFile] {
        let fetchedCourses = PersistenceController.fetchData(context: viewContext, fetchRequest: Course.fetchAll())
        var files: [CSVFile] = []
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_YYYY"
        let fileDate = dateFormatter.string(from: date)
        for course in fetchedCourses {
            // Oral marks
            let oralRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 0, course))
            let oralGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: oralRequest)
            files.append(CSVFile.generateCSVFileOFCourse(course: course, grades: oralGrades, fileName: "\(course.title)_muendlich_" + fileDate))
            // Written marks
            let writtenRequest  = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@", 1, course))
            let writtenGrades = PersistenceController.fetchData(context: viewContext, fetchRequest: writtenRequest)
            files.append(CSVFile.generateCSVFileOFCourse(course: course, grades: writtenGrades, fileName: "\(course.title)_schriftlich_" + fileDate))
            // Transscript marks
            files.append(CSVFile.generateCSVFileOfCourseTranscriptGrade(course: course, fileName: "\(course.title)_zeugnis_" + fileDate))
        }
        return files
        
    }
}
