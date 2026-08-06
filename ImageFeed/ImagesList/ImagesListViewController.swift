//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Sagida on 15.05.2026.
//

import UIKit
import Kingfisher
import ProgressHUD

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
    private let imagesListService = ImagesListService.shared

    private var photos: [Photo] = []
    private var loadedPhotoIDs: Set<String> = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        observeImagesListService()
        imagesListService.fetchPhotosNextPage()
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
    
    private func configCell(_ cell: ImagesListCell, at indexPath: IndexPath) {
        guard indexPath.row < photos.count else { return }
        
        let photo = photos[indexPath.row]
        let imageUrl = URL(string: photo.thumbImageURL)
        
        let dateText: String
        if let createdAt = photo.createdAt {
            dateText = dateFormatter.string(from: createdAt)
        } else {
            dateText = ""
        }
        
        cell.configure(
            imageURL: imageUrl,
            placeholder: UIImage(resource: .photoPlaceholder),
            date: dateText,
            isLiked: photo.isLiked
        ) { [weak self, weak cell] in
            guard
                let self,
                let cell,
                self.loadedPhotoIDs.insert(photo.id).inserted,
                self.tableView.indexPath(for: cell) == indexPath
            else { return }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
//    private func presentSingleImageViewController(for indexPath: IndexPath) {
//        let singleImageViewController = SingleImageViewController()
//        
//        guard let image = UIImage(named: photoNames[indexPath.row]) else {
//            assertionFailure("Could not load image at index \(indexPath.row)")
//            return
//        }
//        
//        singleImageViewController.image = image
//        singleImageViewController.modalPresentationStyle = .fullScreen
//        
//        present(singleImageViewController, animated: true)
//    }
    
    private func observeImagesListService() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateTableViewAnimated()
            }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        
        guard oldCount != newCount else { return }
        
        if newCount > oldCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        } else {
            tableView.reloadData()
        }
    }
    
    private func showLikeErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            assertionFailure("Could not dequeue ImagesListCell")
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(imageListCell, at: indexPath)
        
        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        presentSingleImageViewController(for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else {
            return 44
        }
        
        let photo = photos[indexPath.row]
        
        guard photo.size.width > 0 else {
            return 44
        }
        
        let imageInsets = UIEdgeInsets(top: LayoutConstants.verticalInset, left: LayoutConstants.horizontalInset, bottom: LayoutConstants.verticalInset, right: LayoutConstants.horizontalInset)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let imageHeight = photo.size.height * scale
        
        return imageHeight + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !photos.isEmpty else { return }
        
        let lastRowIndex = photos.count - 1
        
        if indexPath.row == lastRowIndex {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        cell.setIsLiked(newLikeState)
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeState) { [weak self, weak cell] result in
            
            guard let self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                
            case .failure(let error):
                print("[ImagesListViewController.imageListCellDidTapLike]: \(error)")
                cell?.setIsLiked(!newLikeState)
                self.showLikeErrorAlert()
            }
        }
    }
}
