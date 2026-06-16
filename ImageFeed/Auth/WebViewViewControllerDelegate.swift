//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Sagida on 16.06.2026.
//

import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
