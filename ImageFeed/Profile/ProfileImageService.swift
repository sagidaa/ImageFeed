//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Sagida on 22.07.2026.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        task = nil
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: \(NetworkError.missingToken), username: \(username)")
            completion(.failure(NetworkError.missingToken))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.fetchProfileImageURL]: \(NetworkError.invalidRequest), failed to create request, username: \(username)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var newTask: URLSessionTask?
                
        newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self, self.task == newTask else { return }
            
            self.task = nil
            
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                self.avatarURL = profileImageURL
                
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
                
            case .failure(let error):
                print( "[ProfileImageService.fetchProfileImageURL]: \(error), username: \(username)")
                completion(.failure(error))
            }
        }
        
        task = newTask
        newTask?.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let profileImageUrl = URL(string: "\(APIConstants.usersURL)/\(username)") else {
            return nil
        }
        
        var request = URLRequest(url: profileImageUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
