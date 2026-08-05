//
//  NetworkError.swift
//  ImageFeed
//
//  Created by Sagida on 31.07.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
    case missingToken
    case photoNotFound
}
