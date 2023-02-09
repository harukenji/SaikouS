//
//  SceneDelegate.swift
//  Anime Now! (iOS)
//
//  Created by Erik Bautista on 10/9/22.
//
import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let dataController = DataController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = HostingController(
                wrappedView:
                    Search()
            )
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }
        let dic = ["myText": firstUrl.absoluteString.replacingOccurrences(of: "com.saikouswift://redirect?code=", with: "")]
        NotificationCenter.default.post(name: .authCodeUrl, object: nil, userInfo: dic)
        return
    }
}
