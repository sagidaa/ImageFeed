//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Sagida on 22.06.2026.
//

import UIKit


final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() { }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashOAuthTokenURLString) else {
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

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(responseBody.accessToken))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
