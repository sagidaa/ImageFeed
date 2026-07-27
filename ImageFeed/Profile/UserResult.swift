//
//  UserResult.swift
//  ImageFeed
//
//  Created by Sagida on 22.07.2026.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
