//
//  EmptyStateView.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 18/07/2022.
//

import AVKit
import SwiftUI
struct EmptyStateView: View {
    
    @EnvironmentObject var appsManager: AppsManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @StateObject var credentials = CredentialsManager.shared
    
    var body: some View {
        if credentials.allCredentialsAvailable() {
            Text("Select an app to see reviews")
                .font(.system(.title2, design: .rounded))
                .frame(minWidth: 350, maxWidth: 350)
        } else {
            ScrollView {
                VStack {
//                    VideoPlayer(player: AVPlayer(url: URL(string: "https://user-images.githubusercontent.com/170948/180226590-9d938a61-ce20-40ae-8813-311f5d2848de.mp4")!))
//                        .frame(height: 400)
//                        .padding(.horizontal, 40)
                    
                    Text("Add your App Store Connect Credentials")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                    
                    Button {
                        settingsManager.selectedPage = .settings
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
//                        appsManager.selectedPage = .credentials
                    } label: {
                        Text("Add keys")
                    }
                }
            }
        }
    }
}
