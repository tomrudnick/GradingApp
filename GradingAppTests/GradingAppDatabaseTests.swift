//
//  GradingAppTests.swift
//  GradingAppTests
//
//  Created by Tom Rudnick on 08.08.21.
//

import XCTest
import CoreData

@testable import GradingApp

class GradingAppDatabaseTests: XCTestCase {

    var controller: PersistenceController!
    
    var context: NSManagedObjectContext {
        controller.container.viewContext
    }
    let testCourseName = "NAME"
    let testCourseSubject = "KURS"
    let testCourseNameHidden = "KURS_HIDDEN"
    
    let studentFirstName = "Tom"
    let studentLastName = "Rudnick"
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        controller = PersistenceController(inMemory: true)
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        controller = nil
    }
    
    func testAddCourse() throws {
        Course.addCourse(courseName: testCourseName, courseSubject: testCourseSubject, oralWeight: 0, ageGroup: .lower, type: .firstHalf, context: context)
        Course.addCourse(courseName: testCourseNameHidden, courseSubject: testCourseSubject, oralWeight: 0, ageGroup: .lower, type: .firstHalf, hidden: true, context: context)
        
        do {
            let courses = try context.fetch(Course.fetchAll())
            XCTAssert(courses.count == 2)
            XCTAssertNotNil(courses.first(where: {$0.name == testCourseNameHidden }))
            let coursesNonHidden = try context.fetch(Course.fetchAllNonHidden())
            XCTAssert(coursesNonHidden.count == 1)
            XCTAssertNotNil(coursesNonHidden.first(where: {$0.name == testCourseName}))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAddStudent() throws {
        let course = Course(name: testCourseName, subject: testCourseSubject, ageGroup: .lower, type: .firstHalf, oralWeight: 0, context: context)
        context.saveCustom()
        Student.addStudent(firstName: studentFirstName, lastName: studentLastName, email: "", course: course, context: context)
        
        do {
            let students = try context.fetch(Student.fetchRequest()) as [Student]
            XCTAssert(students.count == 1)
            let firstStudent = students.first!
            XCTAssertEqual(firstStudent.firstName, studentFirstName)
            XCTAssertEqual(firstStudent.lastName, studentLastName)
            XCTAssertEqual(firstStudent.course?.name, testCourseName)
            let courses = try context.fetch(Course.fetchAll())
            let testCourse = courses.first(where: {$0.name == testCourseName})!
            let studentsOfTestCourse = testCourse.students
            XCTAssert(studentsOfTestCourse.count == 1)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    
    func testAddManyStudents() {
        let course = Course(name: testCourseName, subject: testCourseSubject, ageGroup: .lower, type: .firstHalf, oralWeight: 0, context: context)
        context.saveCustom()
        let numberOfStudents = 500
        for _ in 1...numberOfStudents {
            Student.addStudent(firstName: randomString(length: 6), lastName: randomString(length: 8), email: "", course: course, context: context)
        }
        do {
            let course = try context.fetch(Course.fetchAll()).first!
            XCTAssert(course.students.count == numberOfStudents)
        } catch {
            XCTFail()
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}


