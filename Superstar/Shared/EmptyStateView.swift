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
    @StateObject var credentials = CredentialsManager.shared
    
    var body: some View {
        if credentials.allCredentialsAvailable() {
            Text("Select an app to see reviews")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
                .frame(minWidth: 400, maxWidth: 500)
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
                        appsManager.selectedPage = .credentials
                    } label: {
                        Text("Add keys")
                    }
                }
            }
        }
    }
}

//struct EmptyStateView_Previews: PreviewProvider {
//    static var previews: some View {
//        EmptyStateView(showCredentialsScreen: .constant(false))
//    }
//}

extension Color {
    static func random() -> Color {
        return Color(
            .displayP3,
            red: Double.random(in: 0...1.0),
            green: Double.random(in: 0...1.0),
            blue: Double.random(in: 0...1.0),
            opacity: 1
        )
    }
}
