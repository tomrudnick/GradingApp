//
//  ExamSummaryComposer.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.11.22.
//

import UIKit


class ExamSummaryComposer: NSObject {
    let pathToExamHTMLTemplate = Bundle.main.path(forResource: "exam", ofType: "html")!
    let pathToGradeSchemaHTMLTemplate = Bundle.main.path(forResource: "gradeSchema", ofType: "html")!
    let pathToGradeHTMLTemplate = Bundle.main.path(forResource: "grade", ofType: "html")!
    
    let exam: Exam
    
    init(exam: Exam) {
        self.exam = exam
    }
    
    private func generateHTMLFile() -> String {
        do {
            var HTMLContent = try String(contentsOfFile: pathToExamHTMLTemplate)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_NAME", with: exam.name)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_DATE", with: exam.date.asString(format: "dd.MM.yyyy"))
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_MAX_POINTS", with: String(format: "%.2f", exam.getMaxPointsPossible()))
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_AVERAGE", with: String(format: "%.2f", exam.getAverage()))
            let failed = exam.getNumberOfGrades(for: exam.failedGrades)
            let totalParticipants = exam.participationCount()
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_FAILED", with: String(failed))
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_PARTICIPANTS", with: String(totalParticipants))
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_PERCENTAGE", with: String(format: "%.2f", (Double(failed) / Double(totalParticipants)) * 100.0))
            
            let gradeSchemaHTMLContent = try String(contentsOfFile: pathToGradeSchemaHTMLTemplate)
            
            let gradeSchema = exam.getPointsToGrade().reduce("") { result, elem in
                var htmlContent = gradeSchemaHTMLContent
                htmlContent = htmlContent.replacingOccurrences(of: "#GRADE", with: String(elem.grade))
                htmlContent = htmlContent.replacingOccurrences(of: "#RANGE", with: elem.range.description)
                return result + htmlContent
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#GRADE_SCHEMA", with: gradeSchema)
            
            let gradeHTMLContent = try String(contentsOfFile: pathToGradeHTMLTemplate)
            let grades = exam.sortedParticipatingStudents.reduce("") { result, student in
                var htmlContent = gradeHTMLContent
                htmlContent = htmlContent.replacingOccurrences(of: "#FIRSTNAME", with: student.firstName)
                htmlContent = htmlContent.replacingOccurrences(of: "#LASTNAME", with: student.lastName)
                htmlContent = htmlContent.replacingOccurrences(of: "#POINTS", with: String(format: "%.2f", exam.getTotalPoints(for: student)))
                htmlContent = htmlContent.replacingOccurrences(of: "#GRADE", with: String(exam.getGrade(for: student)))
                return result + htmlContent
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#GRADES", with: grades)
            
            let gradeToCount = exam.mapGradesToNumberOfOccurences.reversed().reduce("") { result, elem in
                var htmlContent = gradeSchemaHTMLContent
                htmlContent = htmlContent.replacingOccurrences(of: "#GRADE", with: elem.grade)
                htmlContent = htmlContent.replacingOccurrences(of: "#RANGE", with: elem.number)
                return result + htmlContent
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#GRADE_TO_COUNT", with: gradeToCount)
            
            return HTMLContent
            
        } catch {
            print("Something went wrong opening the file")
            return ""
        }
    }
    
    func renderToPDF() -> NSData {
        let htmlContent = generateHTMLFile()
        let printPageRenderer = ExamPrintPageRenderer()
        let printFormatter = UIMarkupTextPrintFormatter(markupText: htmlContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        return pdfData
    }
    
    private func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
}

