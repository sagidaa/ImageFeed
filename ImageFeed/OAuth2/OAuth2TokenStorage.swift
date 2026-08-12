//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Sagida on 25.06.2026.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Properties
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "oauthtoken"
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                
                guard isSuccess else {
                    print("[OAuth2TokenStorage]: Не удалось сохранить токен")
                    return
                }
            } else {
                let isSuccess = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                
                guard isSuccess else {
                    print("[OAuth2TokenStorage]: Не удалось удалить токен")
                    return
                }
            }
        }
    }
}
