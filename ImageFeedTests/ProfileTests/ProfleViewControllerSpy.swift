//
//  ProfleViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Sagida on 20.08.2026.
//

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    var presenter: ProfilePresenterProtocol?

    private(set) var receivedProfile: Profile?
    private(set) var receivedAvatarURL: URL?
    private(set) var showLogoutAlertCalled = false
    private(set) var switchToSplashCalled = false

    func updateProfileDetails(with profile: Profile) {
        receivedProfile = profile
    }

    func updateAvatar(with url: URL) {
        receivedAvatarURL = url
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }

    func switchToSplashViewController() {
        switchToSplashCalled = true
    }
}
