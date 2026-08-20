//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Sagida on 19.08.2026.
//

import UIKit
import OSLog

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didDisplayPhoto(at indexPath: IndexPath)
    func didSelectPhoto(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListService
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Initialization
    
    init(imagesListService: ImagesListService = .shared) {
        self.imagesListService = imagesListService
    }
    
    deinit {
        if let imagesListServiceObserver {
            NotificationCenter.default.removeObserver(imagesListServiceObserver)
        }
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        observeImagesListService()
        updatePhotos()
        imagesListService.fetchPhotosNextPage()
    }
    
    func didDisplayPhoto(at indexPath: IndexPath) {
        guard indexPath.row == imagesListService.photos.count - 1 else { return }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    func didSelectPhoto(at indexPath: IndexPath) {
        guard indexPath.row < imagesListService.photos.count else { return }
        
        let photo = imagesListService.photos[indexPath.row]
        
        guard let imageURL = URL(string: photo.largeImageURLString) else {
            Logger.networking.error("Failed to create full image URL")
            return
        }
        
        view?.showSingleImage(with: imageURL)
    }
    
    func didTapLike(at indexPath: IndexPath) {
        guard indexPath.row < imagesListService.photos.count else { return }
        
        let photo = imagesListService.photos[indexPath.row]
        let newLikeState = !photo.isLiked
        
        view?.setLike(at: indexPath, isLiked: newLikeState)
        view?.setProgressHUDVisible(true)
        
        imagesListService.changeLike( photoId: photo.id, isLike: newLikeState ) { [weak self] result in
            
            guard let self else { return }
            
            self.view?.setProgressHUDVisible(false)
            
            switch result {
            case .success:
                self.updatePhotos()
                
            case .failure(let error):
                Logger.networking.error("Failed to update like for photo \(photo.id): \(error.localizedDescription)")
                
                self.view?.setLike(at: indexPath, isLiked: !newLikeState)
                self.view?.showLikeErrorAlert()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func observeImagesListService() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updatePhotos()
        }
    }
    
    private func updatePhotos() {
        view?.updateTableView(with: imagesListService.photos)
    }
}
