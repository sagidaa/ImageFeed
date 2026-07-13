//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Sagida on 25.06.2026.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
