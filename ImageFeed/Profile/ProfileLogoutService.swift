//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Sagida on 06.08.2026.
//

import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    
    func logout() {
        tokenStorage.token = nil
        
        profileService.clean()
        profileImageService.clean()
        imagesListService.clean()
        
        cleanCookies()
        
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
