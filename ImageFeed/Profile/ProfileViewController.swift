//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sagida on 29.05.2026.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateProfileDetails(with profile: Profile)
    func updateAvatar(with url: URL)
    func showLogoutAlert()
    func switchToSplashViewController()
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let nameFontSize: CGFloat = 23
        static let secondaryFontSize: CGFloat = 13
        
        static let avatarSize: CGFloat = 70
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 32
        static let spacing: CGFloat = 8
        static let buttonSize: CGFloat = 44
        
        static let skeletonHeight: CGFloat = 18
        static let nameSkeletonWidth: CGFloat = 223
        static let loginSkeletonWidth: CGFloat = 89
        static let descriptionSkeletonWidth: CGFloat = 67
    }
    
    // MARK: - Properties
    
    var presenter: ProfilePresenterProtocol?
    
    private let avatarImageView = UIImageView()
    private let logoutButton = UIButton()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let avatarSkeletonView = GradientSkeletonView()
    private let nameSkeletonView = GradientSkeletonView()
    private let loginSkeletonView = GradientSkeletonView()
    private let descriptionSkeletonView = GradientSkeletonView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        startSkeletons()
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - Public Methods
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateAvatar(with url: URL) {
        avatarSkeletonView.isHidden = false
        avatarSkeletonView.startAnimating()
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(resource: .noProfileImageStub)) { [weak self] _ in
            guard let self else { return }
            
            avatarSkeletonView.stopAnimating()
            avatarSkeletonView.isHidden = true
        }
    }
    
    func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty
        ? "Имя не указано"
        : profile.name
        loginNameLabel.text = profile.loginName.isEmpty
        ? "@неизвестный_пользователь"
        : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? "Профиль не заполнен"
        : profile.bio
        
        stopSkeletons()
    }
    
    func switchToSplashViewController() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            print("Failed to get key window")
            return
        }
        
        window.rootViewController = SplashViewController()
    }
    
    func showLogoutAlert() {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else { return }
            presenter?.didConfirmLogout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        alertController.preferredAction = noAction
        
        present(alertController, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func startSkeletons() {
        [avatarSkeletonView, nameSkeletonView, loginSkeletonView, descriptionSkeletonView].forEach {
            $0.isHidden = false
            $0.startAnimating()
        }
    }
    
    private func stopSkeletons() {
        [nameSkeletonView, loginSkeletonView, descriptionSkeletonView].forEach {
            $0.stopAnimating()
            $0.isHidden = true
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .ypBlack
        
        avatarImageView.image = UIImage(resource: .noProfileImageStub)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = LayoutConstants.avatarSize / 2
        avatarImageView.clipsToBounds = true
        
        avatarSkeletonView.layer.cornerRadius = LayoutConstants.avatarSize / 2
        
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
        
        [nameSkeletonView, loginSkeletonView, descriptionSkeletonView].forEach {
            $0.layer.cornerRadius = LayoutConstants.skeletonHeight / 2
            $0.clipsToBounds = true
        }
        
        [avatarImageView, logoutButton, nameLabel, loginNameLabel, descriptionLabel,
         avatarSkeletonView, nameSkeletonView, loginSkeletonView, descriptionSkeletonView].forEach {
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
            
            avatarSkeletonView.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            avatarSkeletonView.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            avatarSkeletonView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            avatarSkeletonView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            
            logoutButton.widthAnchor.constraint(equalToConstant: LayoutConstants.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -LayoutConstants.horizontalInset),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: LayoutConstants.spacing),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: logoutButton.leadingAnchor, constant: -LayoutConstants.spacing),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: LayoutConstants.spacing),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: LayoutConstants.spacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            nameSkeletonView.topAnchor.constraint(equalTo: avatarSkeletonView.bottomAnchor, constant: LayoutConstants.spacing),
            nameSkeletonView.leadingAnchor.constraint(equalTo: avatarSkeletonView.leadingAnchor),
            nameSkeletonView.widthAnchor.constraint(equalToConstant: LayoutConstants.nameSkeletonWidth),
            nameSkeletonView.heightAnchor.constraint(equalToConstant: LayoutConstants.skeletonHeight),
            
            loginSkeletonView.topAnchor.constraint(equalTo: nameSkeletonView.bottomAnchor, constant: LayoutConstants.spacing),
            loginSkeletonView.leadingAnchor.constraint(equalTo: nameSkeletonView.leadingAnchor),
            loginSkeletonView.widthAnchor.constraint(equalToConstant: LayoutConstants.loginSkeletonWidth),
            loginSkeletonView.heightAnchor.constraint(equalToConstant: LayoutConstants.skeletonHeight),
            
            descriptionSkeletonView.topAnchor.constraint(equalTo: loginSkeletonView.bottomAnchor, constant: LayoutConstants.spacing),
            descriptionSkeletonView.leadingAnchor.constraint(equalTo: nameSkeletonView.leadingAnchor),
            descriptionSkeletonView.widthAnchor.constraint(equalToConstant: LayoutConstants.descriptionSkeletonWidth),
            descriptionSkeletonView.heightAnchor.constraint(equalToConstant: LayoutConstants.skeletonHeight)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        presenter?.didTapLogoutButton()
    }
}
