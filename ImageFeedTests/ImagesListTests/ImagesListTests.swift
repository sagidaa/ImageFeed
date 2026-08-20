//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Sagida on 19.08.2026.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {

    @MainActor
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        viewController.configure(presenterSpy)
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    @MainActor
    func testViewControllerCallsDidDisplayPhoto() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        let indexPath = IndexPath(row: 3, section: 0)
        viewController.configure(presenterSpy)
        // when
        viewController.tableView(UITableView(), willDisplay: UITableViewCell(), forRowAt: indexPath)
        // then
        XCTAssertEqual(presenterSpy.displayedPhotoIndexPath, indexPath)
    }

    @MainActor
    func testViewControllerCallsDidSelectPhoto() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        let indexPath = IndexPath(row: 2, section: 0)
        viewController.configure(presenterSpy)
        // when
        viewController.tableView(UITableView(), didSelectRowAt: indexPath)
        // then
        XCTAssertEqual(presenterSpy.selectedPhotoIndexPath, indexPath)
    }

    @MainActor
    func testViewControllerCallsDidTapLike() {
        // given
        let viewController = ImagesListViewController()
        let presenterSpy = ImagesListPresenterSpy()
        let indexPath = IndexPath(row: 1, section: 0)
        viewController.configure(presenterSpy)
        // when
        viewController.didTapLike(at: indexPath)
        // then
        XCTAssertEqual(presenterSpy.likeTappedIndexPath, indexPath)
    }
}
