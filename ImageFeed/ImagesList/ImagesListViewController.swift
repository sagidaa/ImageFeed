//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Sagida on 15.05.2026.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 4
    }
    
    // MARK: - Properties
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let tableView = UITableView()
    private let photoNames: [String] = Array(0..<20).map{"\($0)"}
    private let today = Date()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    // MARK: - Private Methods

    private func setupView() {
        view.backgroundColor = .ypBlack
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            assertionFailure("Could not load image at index \(indexPath.row)")
            return
        }
        
        cell.configure(
            image: image,
            date: dateFormatter.string(from: today),
            isLiked: indexPath.row % 2 == 0
        )
    }
    
    private func presentSingleImageViewController(for indexPath: IndexPath) {
        let singleImageViewController = SingleImageViewController()
        
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            assertionFailure("Could not load image at index \(indexPath.row)")
            return
        }
        
        singleImageViewController.image = image
        singleImageViewController.modalPresentationStyle = .fullScreen
        
        present(singleImageViewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            assertionFailure("Could not dequeue ImagesListCell")
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentSingleImageViewController(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            return 44
        }
        
        let imageInsets = UIEdgeInsets(top: LayoutConstants.verticalInset, left: LayoutConstants.horizontalInset, bottom: LayoutConstants.verticalInset, right: LayoutConstants.horizontalInset)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
