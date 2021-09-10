//
//  SimpleUITest.swift
//  SimpleUITest
//
//  Created by Tom Rudnick on 10.09.21.
//

import XCTest

class SimpleUITest: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
      try super.setUpWithError()
      continueAfterFailure = false

      app = XCUIApplication()
      app.launch()
    }

    func testGameStyleSwitch() throws {
         
        let kurse1HalbjahrNavigationBar = app.navigationBars["Kurse 1.  Halbjahr"]
        kurse1HalbjahrNavigationBar.buttons["Add To Home Screen"].tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Kurs z.B. 11D"]/*[[".cells[\"Fach, Kurs z.B. 11D\"].textFields[\"Kurs z.B. 11D\"]",".textFields[\"Kurs z.B. 11D\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let moreKey = app/*@START_MENU_TOKEN@*/.keys["more"]/*[[".keyboards",".keys[\"Zahlen\"]",".keys[\"more\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        moreKey.tap()
        
        let key = app/*@START_MENU_TOKEN@*/.keys["1"]/*[[".keyboards.keys[\"1\"]",".keys[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        key.tap()
        
        let moreKey2 = app/*@START_MENU_TOKEN@*/.keys["more"]/*[[".keyboards",".keys[\"Buchstaben\"]",".keys[\"more\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        moreKey2.tap()
        

        
        let bKey = app/*@START_MENU_TOKEN@*/.keys["b"]/*[[".keyboards.keys[\"b\"]",".keys[\"b\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        bKey.tap()
        
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Fach"]/*[[".cells[\"Fach\"].buttons[\"Fach\"]",".buttons[\"Fach\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.switches["Mathe"]/*[[".cells[\"Mathe\"].switches[\"Mathe\"]",".switches[\"Mathe\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.cells["Gewichtung"].children(matching: .other).element(boundBy: 0).swipeUp()
        tablesQuery.cells["Speichern"].children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        
                                            
    }
}
