//
//  ExamStudentSummaryComposer.swift
//  GradingApp
//
//  Created by Tom Rudnick on 23.11.22.
//

import UIKit


class ExamStudentSummaryComposer: NSObject {
    let pathToExamHTMLTemplate = Bundle.main.path(forResource: "studentExam", ofType: "html")!
    let pathToGradeSchemaHTMLTemplate = Bundle.main.path(forResource: "gradeSchema", ofType: "html")!
    let pathToGradeHTMLTemplate = Bundle.main.path(forResource: "grade", ofType: "html")!
    
    let exam: Exam
    let student: Student
    
    init(exam: Exam, student: Student) {
        self.exam = exam
        self.student = student
    }
    
    private func generateHTMLStudentExamFile() -> String {
        do {
            var HTMLContent = try String(contentsOfFile: pathToExamHTMLTemplate)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#COURSE", with: exam.course?.title ?? "")
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_NAME", with: exam.name)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_DATE", with: exam.date.asString(format: "dd.MM.yyyy"))
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#FIRSTNAME", with: student.firstName)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LASTNAME", with: student.lastName)
            
            let exercise_names = exam.exercisesArr.map { "<th>\($0.name)</th>"}.reduce("") { $0 + $1 }
            let exercise_max_points = exam.exercisesArr.map { "<td>\(String(format: "%.2f", $0.maxPoints))</td>"}.reduce("") { $0 + $1 }
            let exercise_achieved_points = exam.exercisesArr.map {
                "<td>\(String(format: "%.2f", $0.participationExercises.first { $0.examParticipation?.student == student }?.points ?? 0.0))</td>"
            }.reduce("") { $0 + $1 }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_EXERCISE_NAMES", with: exercise_names)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_EXERCISE_MAX_POINTS", with: exercise_max_points)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_MAX_POINTS", with: String(format: "%.2f", exam.getMaxPointsPossible()))
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_EXERCISE_POINTS", with: exercise_achieved_points)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_SUM_POINTS", with: String(format: "%.2f", exam.getTotalPoints(for: student)))
            
            
            let gradeSchemaHTMLContent = try String(contentsOfFile: pathToGradeSchemaHTMLTemplate)
            
            let gradeSchema = exam.getPointsToGrade().reduce("") { result, elem in
                var htmlContent = gradeSchemaHTMLContent
                htmlContent = htmlContent.replacingOccurrences(of: "#GRADE", with: String(elem.grade))
                htmlContent = htmlContent.replacingOccurrences(of: "#RANGE", with: elem.range.studentDescription)
                return result + htmlContent
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#GRADE_SCHEMA", with: gradeSchema)
            
            let gradeToCount = exam.mapGradesToNumberOfOccurences.reversed().reduce("") { result, elem in
                var htmlContent = gradeSchemaHTMLContent
                htmlContent = htmlContent.replacingOccurrences(of: "#GRADE", with: elem.grade)
                htmlContent = htmlContent.replacingOccurrences(of: "#RANGE", with: elem.number)
                return result + htmlContent
            }
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#GRADE_TO_COUNT", with: gradeToCount)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#GRADE", with: generateGradeString())
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DATE", with: Date().asString(format: "dd.MM.yyyy"))
            HTMLContent = HTMLContent.replacingOccurrences(of: "#EXAM_AVERAGE", with: String(format: "%.2f", exam.getAverage()))
            
            return HTMLContent
            
        } catch {
            print("Something went wrong opening the file")
            return ""
        }
    }
    
    private func generateGradeString() -> String {
        let grade = exam.getGrade(for: student)
        if exam.course?.ageGroup == .lower { return String(grade)}
        else {
            switch grade {
            case 1: return String(format: "%02d Punkt", grade)
            default: return String(format:" %02d Punkte", grade)
            }
        }
    }

    
    func renderToPDF() -> NSData {
        let htmlContentExam = generateHTMLStudentExamFile()
        let printPageRenderer = ExamPrintPageRenderer()
        let printFormatter = UIMarkupTextPrintFormatter(markupText: htmlContentExam)
      
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

