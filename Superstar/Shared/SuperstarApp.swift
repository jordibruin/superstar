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
    
    var body: some Scene {
        WindowGroup {
            FullAppView()
                .frame(minWidth: 800, minHeight: 500)
                .environmentObject(iapManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
    }
}
