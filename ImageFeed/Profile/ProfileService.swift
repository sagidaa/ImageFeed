//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Sagida on 15.07.2026.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.fetchProfile]: \(NetworkError.invalidRequest), failed to create request")
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
                print("[ProfileService.fetchProfile]: \(error), request: \(request.url?.absoluteString ?? "unknown")")
                completion(.failure(error))
            }
        }
        
        task = newTask
        newTask?.resume()
    }
    
    func clean() {
        profile = nil
    }
    
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

