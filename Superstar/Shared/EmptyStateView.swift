//
//  EmptyStateView.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 18/07/2022.
//

import SwiftUI

struct EmptyStateView: View {
    
    @Binding var selectedPage: SettingsPage?
    @StateObject var credentials = CredentialsManager.shared
    
    var body: some View {
        if credentials.allCredentialsAvailable() {
            Text("Select an app to see reviews")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
        } else {
            VStack {
                Text("Add your App Store Connect Credentials")
                    .font(.system(.largeTitle, design: .rounded))
                    .bold()
                Button {
                    selectedPage = .credentials
                } label: {
                    Text("Add keys")
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
