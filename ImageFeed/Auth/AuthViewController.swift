//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Sagida on 15.06.2026.
//

import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let buttonInset: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 90
        
        static let authLogoSize: CGFloat = 60
        static let buttonHeight: CGFloat = 48
    }
    
    // MARK: - Properties
    
    private let oauth2Service = OAuth2Service.shared
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let authLogoImageView = UIImageView()
    private let loginButton = UIButton()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureBackButton()
    }
     
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = .ypBlack
        
        authLogoImageView.image = UIImage(resource: .authScreenLogo)
        authLogoImageView.contentMode = .scaleAspectFit
        
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        
        loginButton.backgroundColor = .ypWhite
        loginButton.layer.cornerRadius = 16
        loginButton.clipsToBounds = true
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        [authLogoImageView, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            authLogoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            authLogoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            authLogoImageView.heightAnchor.constraint(equalToConstant: LayoutConstants.authLogoSize),
            authLogoImageView.widthAnchor.constraint(equalToConstant: LayoutConstants.authLogoSize),
            
            loginButton.heightAnchor.constraint(equalToConstant: LayoutConstants.buttonHeight),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LayoutConstants.buttonInset),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.buttonInset),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.buttonBottomPadding)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBarBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBarBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
    
    private func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    @objc private func didTapLoginButton() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        UIBlockingProgressHUD.show()
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }
            
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print("[AuthViewController.didAuthenticateWithCode]: \(error)")
                self.showAuthErrorAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
