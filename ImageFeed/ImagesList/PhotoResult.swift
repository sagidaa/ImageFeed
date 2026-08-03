//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Sagida on 03.08.2026.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let full: String
    let thumb: String
}
