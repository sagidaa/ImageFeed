//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sagida on 29.05.2026.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let nameFontSize: CGFloat = 23
        static let secondaryFontSize: CGFloat = 13
        
        static let avatarSize: CGFloat = 70
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 32
        static let spacing: CGFloat = 8
        static let buttonSize: CGFloat = 44
    }
    
    // MARK: - Properties
    
    private let avatarImageView = UIImageView()
    private let logoutButton = UIButton()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        guard let profile = profileService.profile else {
            return
        }
        
        updateProfileDetails(with: profile)
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Private Methods
    
    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(resource: .noProfileImageStub))
    }
    
    private func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        loginNameLabel.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            print("Failed to get key window")
            return
        }
        
        window.rootViewController = SplashViewController()
    }
    
    private func setupViews() {
        view.backgroundColor = .ypBlack
        
        avatarImageView.image = UIImage(resource: .noProfileImageStub)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = LayoutConstants.avatarSize / 2
        avatarImageView.clipsToBounds = true
        
        let image = UIImage(resource: .logoutButton)
        logoutButton.setImage(image, for: .normal)
        logoutButton.tintColor = .ypRed
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        
        nameLabel.font = .systemFont(ofSize: LayoutConstants.nameFontSize, weight: .bold)
        nameLabel.textColor = .ypWhite
        
        loginNameLabel.font = .systemFont(ofSize: LayoutConstants.secondaryFontSize)
        loginNameLabel.textColor = .ypGray
        
        descriptionLabel.font = .systemFont(ofSize: LayoutConstants.secondaryFontSize)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.numberOfLines = 0
        
        [avatarImageView, logoutButton, nameLabel, loginNameLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.topInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstants.horizontalInset),
            
            logoutButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -LayoutConstants.horizontalInset),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: LayoutConstants.spacing),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: LayoutConstants.spacing),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: LayoutConstants.spacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: logoutButton.trailingAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        ProfileLogoutService.shared.logout()
        switchToSplashViewController()
    }
}
