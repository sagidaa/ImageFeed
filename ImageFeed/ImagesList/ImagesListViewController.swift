//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Sagida on 15.05.2026.
//

import UIKit
import Kingfisher
import ProgressHUD

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableView(with photos: [Photo])
    func setLike(at indexPath: IndexPath, isLiked: Bool)
    func setProgressHUDVisible(_ isVisible: Bool)
    func showLikeErrorAlert()
    func showSingleImage(with imageURL: URL)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Constants
    
    private enum LayoutConstants {
        static let horizontalInset: CGFloat = 16
        static let verticalInset: CGFloat = 4
        static let fallbackCellHeight: CGFloat = 44
    }
    
    // MARK: - Properties
    
    var presenter: ImagesListPresenterProtocol?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let tableView = UITableView()
    
    private var photos: [Photo] = []
    private var loadedPhotoIDs: Set<String> = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Public Methods
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableView(with newPhotos: [Photo]) {
        let oldCount = photos.count
        let newCount = newPhotos.count
        
        photos = newPhotos
        
        guard oldCount != newCount else { return }
        
        if newCount > oldCount {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        } else {
            tableView.reloadData()
        }
    }
    
    func setLike(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        
        cell.setIsLiked(isLiked)
    }
    
    func setProgressHUDVisible(_ isVisible: Bool) {
        isVisible ? UIBlockingProgressHUD.show() : UIBlockingProgressHUD.dismiss()
    }
    
    func showSingleImage(with imageURL: URL) {
        let singleImageViewController = SingleImageViewController()
        singleImageViewController.fullImageURL = imageURL
        singleImageViewController.modalPresentationStyle = .fullScreen
        
        present(singleImageViewController, animated: true)
    }
    
    func showLikeErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Ок", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    func didTapLike(at indexPath: IndexPath) {
        presenter?.didTapLike(at: indexPath)
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
        let imageUrl = URL(string: photo.thumbImageURLString)
        
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
        presenter?.didSelectPhoto(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < photos.count else {
            return LayoutConstants.fallbackCellHeight
        }
        
        let photo = photos[indexPath.row]
        
        guard photo.size.width > 0 else {
            return LayoutConstants.fallbackCellHeight
        }
        
        let imageInsets = UIEdgeInsets(top: LayoutConstants.verticalInset, left: LayoutConstants.horizontalInset, bottom: LayoutConstants.verticalInset, right: LayoutConstants.horizontalInset)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let imageHeight = photo.size.height * scale
        
        return imageHeight + imageInsets.top + imageInsets.bottom
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.didDisplayPhoto(at: indexPath)
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        didTapLike(at: indexPath)
    }
}
