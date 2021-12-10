//
//  SceneDelegate.swift
//  SearchIOSApp
//
//  Created by Muhammad Usman Tatla on 12/10/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let viewController = AppRouter().getTopViewController()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window
    }
}

