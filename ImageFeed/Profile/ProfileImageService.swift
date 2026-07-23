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
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        task = nil
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.missingToken))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var newTask: URLSessionTask?
        
        newTask = urlSession.data(for: request) { [weak self] result in
            guard let self, self.task == newTask else { return }
            
            self.task = nil
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    let profileImageURL = userResult.profileImage.small
                    self.avatarURL = profileImageURL
                    
                    completion(.success(profileImageURL))
                    
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImageURL]
                    )
                } catch {
                    print("Profile image decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("Profile image request error: \(error)")
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
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
