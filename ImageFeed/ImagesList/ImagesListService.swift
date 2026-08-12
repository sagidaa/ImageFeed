//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Sagida on 03.08.2026.
//

import UIKit

final class ImagesListService {
    
    // MARK: - Properties

    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    private let iso8601DateFormatter = ISO8601DateFormatter()
    
    private(set) var photos: [Photo] = []

    // MARK: - Public Methods

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage) else {
            print("[ImagesListService.fetchPhotosNextPage]: \(NetworkError.invalidRequest), page: \(nextPage)")
            return
        }
                
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            self.task = nil
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map(self.makePhotos)
                
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self)
                
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: \(error), request: \(request.url?.absoluteString ?? "unknown")")
            }
        }
        
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("[ImagesListService.changeLike]: \(NetworkError.invalidRequest), photoId: \(photoId)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let likeResult):
                guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else {
                    print("[ImagesListService.changeLike]: \(NetworkError.photoNotFound), photoId: \(photoId)")
                    completion(.failure(NetworkError.photoNotFound))
                    return
                }
                                
                self.photos[index] = self.makePhotos(from: likeResult.photo)
                
                completion(.success(()))
                
            case .failure(let error):
                print("[ImagesListService.changeLike]: \(error), request: \(request.url?.absoluteString ?? "unknown")")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func clean() {
        task?.cancel()
        task = nil
        
        photos = []
        lastLoadedPage = nil
    }

    // MARK: - Private Methods

    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token,
            var urlComponents = URLComponents(string: APIConstants.photosURL)
        else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makePhotos(from result: PhotoResult) -> Photo {
        let createdAt = result.createdAt.flatMap {
                iso8601DateFormatter.date(from: $0)
            }
        
        return Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: createdAt,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard
            let token = OAuth2TokenStorage.shared.token,
            let urlComponents = URLComponents(string: "\(APIConstants.photosURL)/\(photoId)/like")
        else {
            return nil
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod =  isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
