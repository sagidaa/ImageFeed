//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Sagida on 15.05.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = UIStoryboard(
            name: "Main",
            bundle: .main
        ).instantiateInitialViewController()
        window?.makeKeyAndVisible()
    }
}

