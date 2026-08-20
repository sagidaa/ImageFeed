//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Sagida on 20.08.2026.
//

@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?

    private(set) var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogoutButton() { }

    func didConfirmLogout() { }
}
