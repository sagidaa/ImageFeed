//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Sagida on 24.06.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
    case missingToken
}

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
                    
                    print("[URLSession.data]: \(error.localizedDescription), " +
                          "statusCode: \(statusCode), data: \(responseBody)")
                    
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            } else if let error = error {
                let networkError = NetworkError.urlRequestError(error)
                
                print("[URLSession.data]: \(networkError.localizedDescription), " +
                    "request: \(request.url?.absoluteString ?? "")")
                
                fulfillCompletionOnTheMainThread(.failure(networkError))
            } else {
                let error = NetworkError.urlSessionError
                
                print("[URLSession.data]: \(error.localizedDescription), " +
                      "request: \(request.url?.absoluteString ?? "")")
                
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

                    print("[URLSession.objectTask]: DecodingError - " +
                          "\(error.localizedDescription), data: \(responseBody)")
                    
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("[URLSession.objectTask]: \(error)")
                completion(.failure(error))
            }
        }
        
        return task
    }
}
