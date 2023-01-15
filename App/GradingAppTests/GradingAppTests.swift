//
//  GradingAppTests.swift
//  GradingAppTests
//
//  Created by Tom Rudnick on 25.11.22.
//

import XCTest
import CoreData

@testable import GradingApp

final class GradingAppTests: XCTestCase {
    
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
    

    func testAddManyStudents() throws {
        let course = Course(name: "TestKurs", subject: "TestSubject", context: context)
        context.saveCustom()
        let numberOfStudents = 1000
        for _ in 1...numberOfStudents {
            Student.addStudent(firstName: randomString(length: 6), lastName: randomString(length: 8), email: "", course: course, context: context)
        }
        context.saveCustom()
        
        do {
            let course = try context.fetch(Course.fetchAll()).first!
            XCTAssert(course.students.count == numberOfStudents)
        } catch {
            XCTFail()
        }
    }
    
    func testAddTwoStudents() {
        let course = createStandardCourse()
        createStandardStudents(course: course)
        context.saveCustom()
        let fetchedCourse = try? context.fetch(Course.fetchAllNonHidden()).first
        XCTAssertNotNil(fetchedCourse)
        XCTAssert(fetchedCourse?.students.count == 2)
        XCTAssert(fetchedCourse!.students.contains(where: {$0.firstName == "Tom"}))
        XCTAssert(fetchedCourse!.students.contains(where: {$0.firstName == "Matthias"}))
    }
    
    func testExamNotWrittenShouldNotChangeWrittenGrade(){
        let course = createStandardCourse()
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
    
    
    func testWrittenGradeCorrect() {        
        let course = createStandardCourse()
        createStandardStudents(course: course)
        context.saveCustom()
        let student = try? context.fetch(Course.fetchAllNonHidden()).first?.students.first(where: {$0.firstName == "Tom"})
        guard let student else { XCTFail(); return }
        let grades = addRandomGrades(student: student, type: .written, half: .firstHalf)
        let sumGrade = grades.reduce(0.0) { partialResult, grade in
            partialResult + (grade.multiplier * Double(grade.value))
        }
        let average = sumGrade / Double(grades.count)
        XCTAssertEqual(average, student.totalGradeAverage(half: .firstHalf))
        
    }
    
    func testGradeCorrect() {
        let course = createStandardCourse()
        createStandardStudents(course: course)
        context.saveCustom()
        let student = try? context.fetch(Course.fetchAllNonHidden()).first?.students.first(where: {$0.firstName == "Tom"})
        guard let student else { XCTFail(); return }
        let writtenGrades = addRandomGrades(student: student, type: .written, half: .firstHalf)
        let sumGrade = writtenGrades.reduce(0.0) { partialResult, grade in
            partialResult + (grade.multiplier * Double(grade.value))
        }
        let writtenAverage = sumGrade / Double(writtenGrades.count)
        
        let oralGrades = addRandomGrades(student: student, type: .oral, half: .firstHalf)
        let sumOralGrades = oralGrades.reduce(0.0) { partialResult, grade in
            partialResult + (grade.multiplier * Double(grade.value))
        }
        
        let oralAverage = sumOralGrades / Double(oralGrades.count)
        
        let average = oralAverage * Double(course.oralWeight / 100.0) + writtenAverage * Double(1.0 - (course.oralWeight / 100.0))
        XCTAssertEqual(average, student.totalGradeAverage(half: .firstHalf), accuracy: 0.001)
        
    }
    
    func testGradesInDifferentHalfsShouldNotChangeResult() {
        let course = createStandardCourse()
        createStandardStudents(course: course)
        context.saveCustom()
        let student = try? context.fetch(Course.fetchAllNonHidden()).first?.students.first(where: {$0.firstName == "Tom"})
        guard let student else { XCTFail(); return }
        let _ = addRandomGrades(student: student, type: .written, half: .firstHalf)
        let _ = addRandomGrades(student: student, type: .oral, half: .firstHalf)
        let currentAverage = student.totalGradeAverage(half: .firstHalf)
        let _ = addRandomGrades(student: student, type: .written, half: .secondHalf)
        let _ = addRandomGrades(student: student, type: .oral, half: .secondHalf)
        XCTAssertEqual(currentAverage, student.totalGradeAverage(half: .firstHalf), accuracy: 0.001)
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
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func createStandardCourse() -> Course {
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
