//
//  GradingAppExamTests.swift
//  GradingAppTests
//
//  Created by Matthias Rudnick on 15.01.23.
//

import XCTest
import CoreData
import Foundation

@testable import GradingApp

final class GradingAppExamTests: XCTestCase {

    var controller: PersistenceController!
    
    var context: NSManagedObjectContext {
        controller.container.viewContext
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        controller = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        try super.setUpWithError()
        controller = nil
    }
    
    //Test checks if the written grade does not change, when an exam was
    //written where the studen did not paricipate.
    func testExamNotWrittenShouldNotChangeWrittenGrade(){
        let course = createCourseLower()
        createStandardStudents(course: course)
        let tom = course.students.first { student in
            student.firstName == "Tom"
        }
        let matthias = course.students.first { student in
            student.firstName == "Matthias"
        }
        context.saveCustom()
        _ = addGrades(student: tom!, type: .written, half: .firstHalf, grades: [15,15,15])
        _ = addGrades(student: matthias!, type: .written, half: .firstHalf, grades: [3,3,3])

        let tomWrittenGradeBeforeExam = tom?.gradeAverage(type: .written, half: .firstHalf)
        let matthiasWrittenGradeBeforeExam = matthias?.gradeAverage(type: .written, half: .firstHalf)
        let exam = createExam(course: course)
        exam.addExercise(name: "A1", maxPoints: 4.0)
        exam.addExercise(name: "A2", maxPoints: 2.0)
        exam.addExercise(name: "A3", maxPoints: 6.0)
        let MatthiasExcercise = exam.examParticipations.first { examParticipation in
            examParticipation.student?.firstName == "Matthias"
        }
        let TomExcercise = exam.examParticipations.first { examParticipation in
            examParticipation.student?.firstName == "Tom"
        }
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A1"
        })?.points = 4.0
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A2"
        })?.points = 2.0
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A3"
        })?.points = 5.0
        TomExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A1"
        })?.points = 0.0
        TomExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A2"
        })?.points = 1.0
        TomExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A3"
        })?.points = 2.0
        exam.toggleParticipation(for: tom! )
        let tomWrittenGradeAfterExam = tom?.gradeAverage(type: .written, half: .firstHalf)
        let matthiasWrittenGradeAfterExam = matthias?.gradeAverage(type: .written, half: .firstHalf)
        XCTAssertEqual(tomWrittenGradeBeforeExam, tomWrittenGradeAfterExam)
        XCTAssertNotEqual(matthiasWrittenGradeBeforeExam, matthiasWrittenGradeAfterExam)
    }
    
    //Test checks if exam grade is correctly calculated for student from grade 5-10
    //In this test the student has a maximum of 33 Points.
    
    func testExamGradeCorrectlyCalculatedRandomPointsLower(){
        let course = createCourseLower()
        createStandardStudents(course: course)
        let matthias = course.students.first { student in
            student.firstName == "Matthias"
        }
        context.saveCustom()
        let exam = createExam(course: course)
        exam.addExercise(name: "A1", maxPoints: 4.0)
        exam.addExercise(name: "A2", maxPoints: 2.0)
        exam.addExercise(name: "A3", maxPoints: 6.0)
        exam.addExercise(name: "A4", maxPoints: 3.0)
        exam.addExercise(name: "A5", maxPoints: 5.0)
        exam.addExercise(name: "A6", maxPoints: 7.0)
        exam.addExercise(name: "A7", maxPoints: 6.0)
        
        let totalPointsExam = exam.getMaxPointsPossible()
        
        let MatthiasExcercise = exam.examParticipations.first { examParticipation in
            examParticipation.student?.firstName == "Matthias"
        }
        
        let pointsMatthiasA1 = Double(Int.random(in: 0...4))
        let pointsMatthiasA2 = Double(Int.random(in: 0...2))
        let pointsMatthiasA3 = Double(Int.random(in: 0...6))
        let pointsMatthiasA4 = Double(Int.random(in: 0...3))
        let pointsMatthiasA5 = Double(Int.random(in: 0...5))
        let pointsMatthiasA6 = Double(Int.random(in: 0...7))
        let pointsMatthiasA7 = Double(Int.random(in: 0...6))
       
        
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A1"
        })?.points = pointsMatthiasA1
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A2"
        })?.points = pointsMatthiasA2
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A3"
        })?.points = pointsMatthiasA3
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A4"
        })?.points = pointsMatthiasA4
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A5"
        })?.points = pointsMatthiasA5
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A6"
        })?.points = pointsMatthiasA6
        MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
            examParticipationExercise.exercise?.name == "A7"
        })?.points = pointsMatthiasA7
        
        let totalPointsMatthias = exam.getTotalPoints(for: matthias!)
        
        let percentageMatthias = round(((totalPointsMatthias/totalPointsExam) * 100) * 10 ) / 10
        
        var gradeMatthias = 0
        
        if percentageMatthias >= 87.5 {
            gradeMatthias = 1
        }
        else if percentageMatthias < 87.5 && percentageMatthias >= 75 {
            gradeMatthias = 2
        }
        else if percentageMatthias < 75 && percentageMatthias >= 62.5 {
            gradeMatthias = 3
        }
        else if percentageMatthias < 62.5 && percentageMatthias >= 50 {
            gradeMatthias = 4
        }
        else if percentageMatthias < 50 && percentageMatthias >= 20 {
            gradeMatthias = 5
        }
        else if percentageMatthias < 20 {
            gradeMatthias = 6
        }
        
        let gradeMatthiasApp = exam.getGrade(for: matthias!)
        
        
        XCTAssertEqual(gradeMatthiasApp,gradeMatthias)

    }
    //Test checks if exam grade is correctly calculated for student from grade 5-10
    //In this test the maximal points in the exam is 1000 and all cases from 1 to 1000 points is tested
    
    func testExamGradeCorrectlyCalculatedAllPossiblePointsLower(){
        let course = createCourseLower()
        createStandardStudents(course: course)
        let matthias = course.students.first { student in
            student.firstName == "Matthias"
        }
        context.saveCustom()
        let exam = createExam(course: course)
        exam.addExercise(name: "Aufgabe", maxPoints: 1000)
        
        
        let totalPointsExam = exam.getMaxPointsPossible()
        
        let MatthiasExcercise = exam.examParticipations.first { examParticipation in
            examParticipation.student?.firstName == "Matthias"
        }
        
        for reachedPoints in 0...1000 {
            MatthiasExcercise?.participatedExercises.first(where: { examParticipationExercise in
                examParticipationExercise.exercise?.name == "Aufgabe"
            })?.points = Double(reachedPoints)
            
            
            let totalPointsMatthias = exam.getTotalPoints(for: matthias!)
            
            let percentageMatthias = round(((totalPointsMatthias/totalPointsExam) * 100) * 10 ) / 10
            
            var gradeMatthias = 0
            
            if percentageMatthias >= 87.5 {
                gradeMatthias = 1
            }
            else if percentageMatthias < 87.5 && percentageMatthias >= 75 {
                gradeMatthias = 2
            }
            else if percentageMatthias < 75 && percentageMatthias >= 62.5 {
                gradeMatthias = 3
            }
            else if percentageMatthias < 62.5 && percentageMatthias >= 50 {
                gradeMatthias = 4
            }
            else if percentageMatthias < 50 && percentageMatthias >= 20 {
                gradeMatthias = 5
            }
            else if percentageMatthias < 20 {
                gradeMatthias = 6
            }
            
            let gradeMatthiasApp = exam.getGrade(for: matthias!)
            
            
            XCTAssertEqual(gradeMatthiasApp,gradeMatthias)
        }
    }
    
    


    func addRandomGrades(student: Student, type: GradeType, half: HalfType, count: Int = 1000) -> [Grade] {
        var grades: [Grade] = []
        
        for i in 0..<count {
            let grade = Grade(value: randomGrade(), date: Date(), half: half, type: type, comment: "Grade \(i)", multiplier: 1.0, student: student, context: context)
            grades.append(grade)
        }
        context.saveCustom()
        return grades
    }
    
    func addGrades(student: Student, type: GradeType, half: HalfType, grades: [Int]) -> [Grade] {
        var gradesArray: [Grade] = []
        
        
        for grade in grades {
            let grade = Grade(value: grade, date: Date(), half: half, type: type, comment: "Grade \(grade)", multiplier: 1.0, student: student, context: context)
            gradesArray.append(grade)
        }
        context.saveCustom()
        return gradesArray
    }
    
    
    func createCourseLower() -> Course {
        let course = Course(name: "TestKurs", subject: "TestSubject", ageGroup: .lower, type: .holeYear, oralWeight:
                                Float(Int.random(in: 10...100)), context: context)
        return course
    }
    
    func createStandardStudents(course: Course) {
        Student.addStudent(firstName: "Tom", lastName: "Rudnick", email: "tom@rudnick.ch", course: course, context: context)
        Student.addStudent(firstName: "Matthias", lastName: "Rudnick", email: "matthias@rudnick.ch", course: course, context: context)
    }
    
    func randomString(length: Int) -> String {
         let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
         return String((0..<length).map{ _ in letters.randomElement()! })
       }
    
    func randomGrade() -> Int {
        Int.random(in: 0...15)
    }
    
    func createExam(course: Course) -> Exam {
        let exam = Exam(context: context)
        exam.setup(course: course, half: .firstHalf)
        exam.name = "Testarbeit"
        
        return exam
    }
}
