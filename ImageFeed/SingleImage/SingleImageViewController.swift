//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Sagida on 01.06.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {

    // MARK: - IB Outlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    // MARK: - Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        imageView.image = image
        
        if let image  {
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - Image Layout
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()

        let boundsSize = scrollView.bounds.size
        let imageSize = image.size

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
    
    // MARK: - Actions

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let vc = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(vc, animated: true, completion: nil)
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
