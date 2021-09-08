//
//  EditGradesPerDateViewModelTest.swift
//  EditGradesPerDateViewModelTest
//
//  Created by Tom Rudnick on 08.09.21.
//

import XCTest
@testable import GradingApp
import CoreData

class EditGradesPerDateViewModelTest: XCTestCase {
    
    var controller: PersistenceController!
    var viewModel: EditGradesPerDateViewModel!
    
    var dateToday: Date!
    var dateTomorrow: Date!
    var dateInTwoDays: Date!

    var context: NSManagedObjectContext {
        controller.container.viewContext
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        controller = PersistenceController(inMemory: true)
        dateToday = Date()
        var dayComponent    = DateComponents()
        dayComponent.day    = 1 // For removing one day (yesterday): -1
        let theCalendar     = Calendar.current
        dateTomorrow        = theCalendar.date(byAdding: dayComponent, to: Date())!
        dayComponent.day    = 2
        dateInTwoDays       = theCalendar.date(byAdding: dayComponent, to: Date())!
        generateTestData()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        controller = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    
    func testViewModelAttributes() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let course = try! context.fetch(Course.fetchAll()).first!
        let request = Grade.fetch(NSPredicate(format: "type = %d AND student.course = %@ AND half = %d", 0, course, 0))
        let grades = try! context.fetch(request)
        let gradesPerDates = Grade.getGradesPerDate(grades: grades)
        let todayGrades = gradesPerDates[dateToday]
        XCTAssertNotNil(todayGrades)
        viewModel = EditGradesPerDateViewModel(studentGrades: todayGrades!, course: course)
        XCTAssertNotNil(viewModel.comment)
        XCTAssertEqual(viewModel.comment!, "")
        XCTAssertNotNil(viewModel.gradeMultiplier)
        XCTAssertEqual(viewModel.gradeMultiplier!, 1.0)
        XCTAssertEqual(viewModel.gradeType, .oral)
        XCTAssertEqual(viewModel.date, dateToday)
        
        let tomorrowGrades = gradesPerDates[dateTomorrow]
        XCTAssertNotNil(tomorrowGrades)
        viewModel = EditGradesPerDateViewModel(studentGrades: tomorrowGrades!, course: course)
        XCTAssertNil(viewModel.comment)
        XCTAssertNotNil(viewModel.gradeMultiplier)
        XCTAssertEqual(viewModel.gradeMultiplier!, 1.0)
        XCTAssertEqual(viewModel.gradeType, .oral)
        XCTAssertEqual(viewModel.date, dateTomorrow)
        
        let inTwoDaysGrades = gradesPerDates[dateInTwoDays]
        XCTAssertNotNil(tomorrowGrades)
        viewModel = EditGradesPerDateViewModel(studentGrades: inTwoDaysGrades!, course: course)
        XCTAssertNotNil(viewModel.comment)
        XCTAssertEqual(viewModel.comment!, "LZK")
        XCTAssertNil(viewModel.gradeMultiplier)
        XCTAssertNil(viewModel.gradeMultiplier)
        XCTAssertEqual(viewModel.gradeType, .oral)
        XCTAssertEqual(viewModel.date, dateInTwoDays)
    }
    
    func generateTestData() {
        let course = Course(name: "10f", subject: "Mathe", ageGroup: .lower, type: .firstHalf, oralWeight: 50, context: context)
        let studentTom = Student(firstName: "Tom", lastName: "Rudnick", email: "tom@rudnick.ch", course: course, context: context)
        let studentJack = Student(firstName: "Jack", lastName: "Rudnick", email: "jack@rudnick.ch", course: course, context: context)
        let studentEszter = Student(firstName: "Eszter", lastName: "kannIchNichtSchreiben", email: "eszter@gmail.com", course: course, context: context)
        let studentHendrik = Student(firstName: "Hendrik", lastName: "Hagedorn", email: "hendrik.hagedorn@gmail.com", course: course, context: context)
        
        Grade.addGrade(value: 10, date: dateToday, half: .firstHalf, type: .oral, comment: "", multiplier: 1.0, student: studentTom, context: context)
        Grade.addGrade(value: 12, date: dateToday, half: .firstHalf, type: .oral, comment: "", multiplier: 1.0, student: studentJack, context: context)
        Grade.addGrade(value: 6, date: dateToday, half: .firstHalf, type: .oral, comment: "", multiplier: 1.0, student: studentEszter, context: context)
        Grade.addGrade(value: 7, date: dateToday, half: .firstHalf, type: .oral, comment: "", multiplier: 1.0, student: studentHendrik, context: context)
        
        
        Grade.addGrade(value: 5, date: dateTomorrow, half: .firstHalf, type: .oral, comment: "LZK", multiplier: 1.0, student: studentTom, context: context)
        Grade.addGrade(value: 6, date: dateTomorrow, half: .firstHalf, type: .oral, comment: "", multiplier: 1.0, student: studentJack, context: context)
        Grade.addGrade(value: 8, date: dateTomorrow, half: .firstHalf, type: .oral, comment: "LZK", multiplier: 1.0, student: studentEszter, context: context)
        Grade.addGrade(value: 7, date: dateTomorrow, half: .firstHalf, type: .oral, comment: "", multiplier: 1.0, student: studentHendrik, context: context)
        
        Grade.addGrade(value: 5, date: dateInTwoDays, half: .firstHalf, type: .oral, comment: "LZK", multiplier: 1.0, student: studentTom, context: context)
        Grade.addGrade(value: 7, date: dateInTwoDays, half: .firstHalf, type: .oral, comment: "LZK", multiplier: 2.0, student: studentHendrik, context: context)
        
    }
}
