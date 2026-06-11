//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sagida on 29.05.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
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
    private let fullNameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let bioLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .ypBlack
        
        avatarImageView.image = UIImage(resource: .mockProfile)
        avatarImageView.layer.cornerRadius = Constants.avatarSize / 2
        avatarImageView.clipsToBounds = true
        
        let image = UIImage(resource: .logoutButton)
        logoutButton.setImage(image, for: .normal)
        logoutButton.tintColor = .ypRed
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        fullNameLabel.text = "Екатерина Новикова"
        fullNameLabel.font = .systemFont(ofSize: Constants.nameFontSize, weight: .bold)
        fullNameLabel.textColor = .ypWhite
        
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.font = .systemFont(ofSize: Constants.secondaryFontSize)
        usernameLabel.textColor = .ypGray
        
        bioLabel.text = "Hello, world!"
        bioLabel.font = .systemFont(ofSize: Constants.secondaryFontSize)
        bioLabel.textColor = .ypWhite
        
        [avatarImageView, logoutButton, fullNameLabel, usernameLabel, bioLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topInset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.horizontalInset),
            
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            logoutButton.heightAnchor.constraint(equalTo: logoutButton.widthAnchor),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.horizontalInset),
            
            fullNameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.spacing),
            fullNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: Constants.spacing),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            bioLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: Constants.spacing),
            bioLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func logoutTapped() {
        print("logout")
    }
}
