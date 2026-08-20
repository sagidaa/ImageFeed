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
        
        app.launch()
    }
    
    @MainActor
    func testAuth() throws {
        let authButton = app.buttons["authButton"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("sagida.karzhaubayeva@gmail.com")//<Ваш e-mail>
        app.buttons["Done"].tap()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 2))
        passwordTextField.typeText("Todaydont4331*")//<Ваш пароль>
        app.buttons["Done"].tap()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 10))

        cell.swipeUp()
        sleep(2)

        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        let likeButton = cellToLike.buttons["likeButton"]

        XCTAssertTrue(likeButton.waitForExistence(timeout: 5))
        
        let valueBeforeTap = likeButton.value as? String
        let expectedValue = valueBeforeTap == "liked" ? "not liked" : "liked"

        likeButton.tap()

        let likedPredicate = NSPredicate(format: "value == %@", expectedValue)
        expectation(for: likedPredicate, evaluatedWith: likeButton)
        waitForExpectations(timeout: 10)

        XCTAssertEqual(likeButton.value as? String, expectedValue)

        cellToLike.tap()
        sleep(2)

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
        let profileTab = app.tabBars.buttons["profileTab"]

        XCTAssertTrue(profileTab.waitForExistence(timeout: 10))
        profileTab.tap()

        let name = app.staticTexts["Sagida K"]
        let login = app.staticTexts["@sagidaa"]

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
