//
//  EmptyStateView.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 18/07/2022.
//

import SwiftUI

struct EmptyStateView: View {
    @Binding var showCredentialsScreen: Bool
    
    @StateObject var credentials = CredentialsManager.shared
    
    var body: some View {
        if credentials.allCredentialsAvailable() {
            Text("Select an app to see reviews")
        } else {
            VStack {
                Text("Add your App Store Connect Credentials")
                Button {
                    showCredentialsScreen = true
                } label: {
                    Text("Add keys")
                }
            }
        }
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView(showCredentialsScreen: .constant(false))
    }
}
