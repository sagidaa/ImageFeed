//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Sagida on 22.06.2026.
//

import Foundation


final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() { }
    
    private let storage = OAuth2TokenStorage.shared
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else { return }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            task = nil
            lastCode = nil
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseBody):
                self.storage.token = responseBody.accessToken
                completion(.success(responseBody.accessToken))
                
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: \(error), code: \(code)")
                completion(.failure(error))
            }
            
            if self.lastCode == code {
                self.task = nil
                self.lastCode = nil
            }
        }
        
        task?.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: APIConstants.unsplashOAuthTokenURLString) else {
            print("[OAuth2Service.makeOAuthTokenRequest]: invalid URLComponents, code: \(code)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            print("[OAuth2Service.makeOAuthTokenRequest]: failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
}
