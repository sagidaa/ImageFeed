//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sagida on 29.05.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    
    @IBOutlet private var profileImageView: UIImageView!
    @IBOutlet private var logoutButton: UIButton!
    
    @IBOutlet private var fullNameLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var bioLabel: UILabel!
    
    @IBAction private func didTapLogoutButton(_ sender: Any) {
    }
}
