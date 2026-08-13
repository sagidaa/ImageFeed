//
//  Photo.swift
//  ImageFeed
//
//  Created by Sagida on 03.08.2026.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURLString: String
    let largeImageURLString: String
    let isLiked: Bool
}
