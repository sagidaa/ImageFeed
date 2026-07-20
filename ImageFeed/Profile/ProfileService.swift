//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Sagida on 15.07.2026.
//

import Foundation

final class ProfileService {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
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
                    
                    let profileResult = try decoder.decode(ProfileResult.self, from: data)
                    let profile = self.makeProfile(from: profileResult)
                    
                    completion(.success(profile))
                } catch {
                    print("Profile decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("Profile request error: \(error)")
                completion(.failure(error))
            }
        }
        
        task = newTask
        newTask?.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let profileUrl = URL(string: APIConstants.profileURL) else {
            return nil
        }
        
        var request = URLRequest(url: profileUrl)
        request.httpMethod = "GET"
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

