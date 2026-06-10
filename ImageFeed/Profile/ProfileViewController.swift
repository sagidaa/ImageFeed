//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sagida on 29.05.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let profileImageView = UIImageView()
    private let logoutButton = UIButton()
    private let fullNameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let bioLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
}

// MARK: - Layout Constants

private extension ProfileViewController {
    enum Layout {
        static let nameFontSize: CGFloat = 23
        static let secondaryFontSize: CGFloat = 13
        
        static let avatarSize: CGFloat = 70
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 32
        static let spacing: CGFloat = 8
        static let buttonSize: CGFloat = 44
    }
}

// MARK: - UI Setup

private extension ProfileViewController {
    func setupViews() {
        view.backgroundColor = .ypBlack
        
        profileImageView.image = UIImage(resource: .mockProfile)
        profileImageView.layer.cornerRadius = Layout.avatarSize / 2
        profileImageView.clipsToBounds = true
        
        let image = UIImage(resource: .logoutButton)
        logoutButton.setImage(image, for: .normal)
        logoutButton.tintColor = .ypRed
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        fullNameLabel.text = "Екатерина Новикова"
        fullNameLabel.font = .systemFont(ofSize: Layout.nameFontSize, weight: .bold)
        fullNameLabel.textColor = .ypWhite
        
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = .systemFont(ofSize: Layout.secondaryFontSize)
        usernameLabel.textColor = .ypGray
        
        bioLabel.text = "Hello, world!"
        bioLabel.font = .systemFont(ofSize: Layout.secondaryFontSize)
        bioLabel.textColor = .ypWhite
        
        [profileImageView, logoutButton, fullNameLabel, usernameLabel, bioLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: Layout.avatarSize),
            profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Layout.topInset),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Layout.horizontalInset),
            
            logoutButton.widthAnchor.constraint(equalToConstant: Layout.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Layout.horizontalInset),
            
            fullNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: Layout.spacing),
            fullNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: Layout.spacing),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Layout.spacing),
            bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor)
        ])
    }
}

// MARK: - Actions

private extension ProfileViewController {
    @objc func logoutTapped() {
        print("logout")
    }
}
