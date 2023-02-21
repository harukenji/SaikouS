//
//  MacOSApplicationEntry.swift
//  Saikou Beta
//
//  Created by Inumaki on 20.02.23.
//
#if os(macOS)
import SwiftUI

@main
struct AnimeNowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        WindowGroup {
            Search()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.expanded)

        Settings {
            VStack {
                Text("SETTINGS")
            }
            .frame(width: 325, height: 550)
        }
    }
}
#endif
