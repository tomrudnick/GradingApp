//
//  GradingAppUITests.swift
//  GradingAppUITests
//
//  Created by Tom Rudnick on 16.01.23.
//

import XCTest

final class GradingAppUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        app.launch()
        app.navigationBars["Kurse 1.  HJ, 23/24"]/*@START_MENU_TOKEN@*/.buttons["Bearbeiten"]/*[[".otherElements[\"Bearbeiten\"].buttons[\"Bearbeiten\"]",".buttons[\"Bearbeiten\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.toolbars["Toolbar"]/*@START_MENU_TOKEN@*/.buttons["Hinzufügen"]/*[[".otherElements[\"Hinzufügen\"].buttons[\"Hinzufügen\"]",".buttons[\"Hinzufügen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Fach"]/*[[".cells.buttons[\"Fach\"]",".buttons[\"Fach\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        app.navigationBars["Fach auswählen"]/*@START_MENU_TOKEN@*/.buttons["Hinzufügen"]/*[[".otherElements[\"Hinzufügen\"].buttons[\"Hinzufügen\"]",".buttons[\"Hinzufügen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let collectionViewsQuery2 = app.collectionViews
        app.textFields["Z.B. Mathe"].tap()
        app.textFields["Z.B. Mathe"].typeText("Informatik")
        
        //app.buttons["Hinnzufügen"].tap()
        let buttons = app.buttons.matching(identifier: "Hinzufügen")
        buttons.element(boundBy: 0).tap()
        app.buttons["Informatik"].tap()
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    


    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
