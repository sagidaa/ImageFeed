//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Sagida on 20.08.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testAuth() throws {
        app.launch()
        
        let authButton = app.buttons["authButton"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        app.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 2))
        passwordTextField.typeText("<Ваш пароль>")
        app.buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testFeed() throws {
        app.launch()
        
        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 10))
        
        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        
        table.swipeUp(velocity: .slow)
            
        let cell = table.cells.element(boundBy: 1)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        
        if !cell.isHittable {
            table.swipeUp(velocity: .slow)
        }
        
        XCTAssertTrue(cell.isHittable)
        
        let likeButton = cell.buttons["likeButton"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        XCTAssertTrue(likeButton.isHittable)
        
        likeButton.tap()
        sleep(2)
        
        likeButton.tap()
        sleep(2)
        
        cell.tap()
        
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButton = app.buttons["navBackButton"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testProfile() throws {
        app.launch()
        
        let profileTab = app.tabBars.buttons["profileTab"]
        
        XCTAssertTrue(profileTab.waitForExistence(timeout: 10))
        profileTab.tap()
        
        let name = app.staticTexts["Profile name"]
        let login = app.staticTexts["@username"]
        
        XCTAssertTrue(name.waitForExistence(timeout: 10))
        XCTAssertTrue(login.exists)
        
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        let logoutAlert = app.alerts["Пока, пока!"]
        XCTAssertTrue(logoutAlert.waitForExistence(timeout: 3))
        
        logoutAlert.buttons["Да"].tap()
        
        XCTAssertTrue(app.buttons["authButton"].waitForExistence(timeout: 10))
    }
}
