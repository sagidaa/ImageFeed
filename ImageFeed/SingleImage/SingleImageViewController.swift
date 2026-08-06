//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Sagida on 01.06.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let minimumZoomScale: CGFloat = 0.1
        static let maximumZoomScale: CGFloat = 1.25
                
        static let backButtonInset: CGFloat = 8
        static let shareButtonInset: CGFloat = 16
        static let backButtonSize: CGFloat = 44
        static let shareButtonSize: CGFloat = 50
    }
    
    // MARK: - Properties
    
    var fullImageURL: URL?
    
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let backButton = UIButton()
    private let shareButton = UIButton()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        loadFullImage()
    }
    
    // MARK: - Private Methods
    
    private func loadFullImage() {
        guard let fullImageURL else {
            showError()
            return
        }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: fullImageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let imageResult):
                self.configureImage(with: imageResult.image)
                
            case .failure(let error):
                print("[SingleImageViewController.loadFullImage]: \(error)")
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadFullImage()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(retryAction)

        present(alertController, animated: true)
        
    }
    
    private func configureImage(with image: UIImage) {
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func setupViews() {
        view.backgroundColor = .ypBlack
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = LayoutConstants.minimumZoomScale
        scrollView.maximumZoomScale = LayoutConstants.maximumZoomScale
        scrollView.backgroundColor = .ypBlack
        
        imageView.contentMode = .scaleAspectFit
        
        let backButtonImage = UIImage(resource: .navBarBackButton)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.tintColor = .ypWhite
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        let shareButtonImage = UIImage(resource: .shareButton)
        shareButton.tintColor = .ypWhite
        shareButton.setImage(shareButtonImage, for: .normal)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        [scrollView, backButton, shareButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        scrollView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            backButton.heightAnchor.constraint(equalToConstant: LayoutConstants.backButtonSize),
            backButton.widthAnchor.constraint(equalToConstant: LayoutConstants.backButtonSize),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.backButtonInset),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: LayoutConstants.backButtonInset),
            
            shareButton.heightAnchor.constraint(equalToConstant: LayoutConstants.shareButtonSize),
            shareButton.widthAnchor.constraint(equalToConstant: LayoutConstants.shareButtonSize),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutConstants.shareButtonInset)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapShareButton() {
        guard let image = imageView.image else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityViewController, animated: true)
    }
    
    // MARK: - Image Layout
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        let boundsSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard imageSize.width > 0, imageSize.height > 0 else { return }
        
        let hScale = boundsSize.width / imageSize.width
        let vScale = boundsSize.height / imageSize.height
        
        scrollView.zoomScale = max(hScale, vScale)
        
        centerImage()
        
        let offsetX = max(0, (scrollView.contentSize.width - boundsSize.width) / 2)
        let offsetY = max(0, (scrollView.contentSize.height - boundsSize.height) / 2)
        
        scrollView.contentOffset = CGPoint(x: offsetX, y: offsetY)
    }
    
    private func centerImage() {
        let boundsSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let horizontalInset = max(0, (boundsSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (boundsSize.height - contentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
