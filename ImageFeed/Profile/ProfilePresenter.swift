//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Sagida on 19.08.2026.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogoutButton()
    func didConfirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Properties

    weak var view: ProfileViewControllerProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    private let notificationCenter: NotificationCenter

    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Initialization

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
        profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared,
        notificationCenter: NotificationCenter = .default
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
        self.notificationCenter = notificationCenter
    }

    deinit {
        if let profileImageServiceObserver {
            notificationCenter.removeObserver(profileImageServiceObserver)
        }
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        observeProfileImageService()
        
        if let profile = profileService.profile {
            view?.updateProfileDetails(with: profile)
        }
        
        updateAvatar()
    }
    
    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }
    
    func didConfirmLogout() {
        profileLogoutService.logout()
        view?.switchToSplashViewController()
    }
    
    private func observeProfileImageService() {
        guard profileImageServiceObserver == nil else { return }

        profileImageServiceObserver = notificationCenter.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateAvatar() {
        guard
            let avatarURL = profileImageService.avatarURL,
            let url = URL(string: avatarURL)
        else { return }

        view?.updateAvatar(with: url)
    }
}
