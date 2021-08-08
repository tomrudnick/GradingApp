//
//  EditViewModelTest.swift
//  GradingAppTests
//
//  Created by Tom Rudnick on 08.08.21.
//

import XCTest
import CoreData

@testable import GradingApp

class EditViewModelTest: XCTestCase {
    
    var editVM: CourseEditViewModel!

    var controller: PersistenceController!
    
    var context: NSManagedObjectContext {
        controller.container.viewContext
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        editVM = CourseEditViewModel()
        controller = PersistenceController(inMemory: true)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        editVM = nil
        controller = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
