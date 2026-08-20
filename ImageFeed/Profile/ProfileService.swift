//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Sagida on 15.07.2026.
//

import Foundation
import OSLog

protocol ProfileServiceProtocol: AnyObject {
    var profile: Profile? { get }
}

final class ProfileService: ProfileServiceProtocol {
    
    // MARK: - Properties
    
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?

    // MARK: - Public Methods

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            Logger.networking.error("Failed to create profile request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var newTask: URLSessionTask?
        
        newTask = urlSession.objectTask(for: request) { [weak self] (result:Result<ProfileResult, Error>) in
            guard let self, self.task == newTask else { return }
            
            self.task = nil
            
            switch result {
            case .success(let profileResult):
                let profile = self.makeProfile(from: profileResult)
                self.profile = profile
                completion(.success(profile))
                
            case .failure(let error):
                Logger.networking.error("Failed to fetch profile \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task = newTask
        newTask?.resume()
    }
    
    func clean() {
        profile = nil
    }

    // MARK: - Private Methods

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let profileUrl = URL(string: APIConstants.profileURL) else {
            return nil
        }
        
        var request = URLRequest(url: profileUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func makeProfile(from result: ProfileResult) -> Profile {
        let name = [
            result.firstName,
            result.lastName
        ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        
        return Profile(
            username: result.username,
            name: name,
            loginName: "@\(result.username)",
            bio: result.bio
        )
    }
}

