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
    
    func fetchAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            task = nil
            lastCode = nil
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task = urlSession.data(for: request) { [weak self] result in
            guard let self else {
                completion(.failure(NetworkError.invalidRequest))
                return
            }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.storage.token = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
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
            print("Error: failed to create URLComponents from string")
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
            print("Error: failed to construct URL from components")
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
}
