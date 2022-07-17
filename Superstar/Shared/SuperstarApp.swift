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
    
    var body: some Scene {
        WindowGroup {
            FullAppView()
                .frame(minWidth: 700, minHeight: 500)
        }
        .windowToolbarStyle(.automatic)
        .windowStyle(.titleBar)
    }
}
