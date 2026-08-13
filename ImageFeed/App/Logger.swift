//
//  Logger.swift
//  ImageFeed
//
//  Created by Sagida on 13.08.2026.
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "ImageFeed"
    
    static let authorization = Logger(
        subsystem: subsystem,
        category: "Authorization"
    )
    
    static let networking = Logger(
        subsystem: subsystem,
        category: "Networking"
    )
}
