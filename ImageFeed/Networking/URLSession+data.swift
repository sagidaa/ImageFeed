//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Sagida on 24.06.2026.
//

import Foundation
import OSLog

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping(Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let error = NetworkError.httpStatusCode(statusCode)
                    let responseBody = String(data: data, encoding: .utf8) ?? ""
                    
                    Logger.networking.error("Request failed with HTTP status code \(statusCode)")
                    
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            } else if let error = error {
                let networkError = NetworkError.urlRequestError(error)
                
                Logger.networking.error("URL request failed: \(error.localizedDescription)")
                
                fulfillCompletionOnTheMainThread(.failure(networkError))
            } else {
                let error = NetworkError.urlSessionError
                
                Logger.networking.error("URLSession completed without data, response, or error")
                
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        }
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    let responseBody = String(data: data, encoding: .utf8) ?? ""

                    Logger.networking.error("Failed to decode server response: \(error.localizedDescription)")
                    
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
