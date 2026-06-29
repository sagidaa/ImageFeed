//
//  AuthViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Sagida on 29.06.2026.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
