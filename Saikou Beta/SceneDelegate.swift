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
                    Home()
                        .environment(\.managedObjectContext, dataController.container.viewContext)
            )
            self.window = window
            window.makeKeyAndVisible()
            
            #if targetEnvironment(macCatalyst)
            if let titlebar = windowScene.titlebar {
                titlebar.titleVisibility = .hidden
                titlebar.toolbar = nil
            }
            #endif
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }
        let dic = ["myText": String(firstUrl.absoluteString.replacingOccurrences(of: "com.saikouswift://redirect#access_token=", with: "").split(separator: "&")[0])]
        NotificationCenter.default.post(name: .authCodeUrl, object: nil, userInfo: dic)
        return
    }
}
