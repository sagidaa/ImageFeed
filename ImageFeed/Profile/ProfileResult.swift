//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Sagida on 15.07.2026.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}
