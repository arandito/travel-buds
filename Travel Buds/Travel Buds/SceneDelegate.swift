//
//  SceneDelegate.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 11/8/23.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
        var window: UIWindow?

        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = UIHostingController(rootView: LoginView()) // Use your initial SwiftUI view here
                self.window = window
                window.makeKeyAndVisible()
            }
        }
}




