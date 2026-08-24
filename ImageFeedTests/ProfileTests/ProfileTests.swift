//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Sagida on 20.08.2026.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    @MainActor
    func testViewControllerCallsPresenterViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy)
        // when
        _ = viewController.view
        // then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    @MainActor
    func testPresenterUpdatesProfileDetails() {
        // given
        let profile = Profile(
            username: "ekaterina_nov",
            name: "Екатерина Новикова",
            loginName: "@ekaterina_nov",
            bio: "Hello, world!"
        )

        let profileService = ProfileServiceMock(profile: profile)
        let imageService = ProfileImageServiceMock()
        let logoutService = ProfileLogoutServiceMock()
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: imageService,
            profileLogoutService: logoutService
        )
        presenter.view = viewControllerSpy
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertEqual(viewControllerSpy.receivedProfile?.name, "Екатерина Новикова")
        XCTAssertEqual(viewControllerSpy.receivedProfile?.loginName, "@ekaterina_nov")
    }

    @MainActor
    func testPresenterUpdatesAvatar() {
        // given
        let imageService = ProfileImageServiceMock(
            avatarURL: "https://example.com/avatar.jpg"
        )
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceMock(profile: nil),
            profileImageService: imageService,
            profileLogoutService: ProfileLogoutServiceMock()
        )
        presenter.view = viewControllerSpy
        // when
        presenter.viewDidLoad()
        // then
        XCTAssertEqual(
            viewControllerSpy.receivedAvatarURL,
            URL(string: "https://example.com/avatar.jpg")
        )
    }

    @MainActor
    func testPresenterShowsLogoutAlert() {
        // given
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceMock(profile: nil),
            profileImageService: ProfileImageServiceMock(),
            profileLogoutService: ProfileLogoutServiceMock()
        )
        presenter.view = viewControllerSpy
        // when
        presenter.didTapLogoutButton()
        // then
        XCTAssertTrue(viewControllerSpy.showLogoutAlertCalled)
    }

    @MainActor
    func testPresenterLogsOutAndSwitchesToSplashScreen() {
        // given
        let logoutService = ProfileLogoutServiceMock()
        let viewControllerSpy = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceMock(profile: nil),
            profileImageService: ProfileImageServiceMock(),
            profileLogoutService: logoutService
        )
        presenter.view = viewControllerSpy
        // when
        presenter.didConfirmLogout()
        // then
        XCTAssertTrue(logoutService.logoutCalled)
        XCTAssertTrue(viewControllerSpy.switchToSplashCalled)
    }
}

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: Profile?

    init(profile: Profile? = nil) {
        self.profile = profile
    }
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String?

    init(avatarURL: String? = nil) {
        self.avatarURL = avatarURL
    }
}

final class ProfileLogoutServiceMock: ProfileLogoutServiceProtocol {
    private(set) var logoutCalled = false

    func logout() {
        logoutCalled = true
    }
}
