//
//  SuperstarApp.swift
//  Shared
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI

@main
struct SuperstarApp: App {
    
    @NSApplicationDelegateAdaptor(StatusBarDelegate.self) var appDelegate
    
    @StateObject var iapManager = IAPManager.shared
    @StateObject var appsManager = AppsManager()
    @StateObject var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            FullAppView()
                .frame(minWidth: 800, minHeight: 500)
                .environmentObject(iapManager)
                .environmentObject(appsManager)
                .environmentObject(settingsManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        
        Settings {
            PreferencesView()
                .environmentObject(appsManager)
                .environmentObject(settingsManager)
        }
    }
}

class SettingsManager: ObservableObject {
    @Published var selectedPage: SettingsPage = .settings
}
