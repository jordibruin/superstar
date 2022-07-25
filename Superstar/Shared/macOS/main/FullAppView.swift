//
//  FullAppView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct FullAppView: View {
    
    @StateObject var reviewManager = ReviewManager()
    @StateObject var appsManager = AppsManager()
    
    @State var showCredentialsScreen = false
    @State var showSuggestionsScreen = false
//    @State var showSettings = false
//    @State var showHomeScreen = false
    
    @StateObject var credentials = CredentialsManager.shared
    
    @AppStorage("hiddenAppIds") var hiddenAppIds: [String] = []
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    @State var selectedReview: CustomerReview?
    
    var body: some View {
        NavigationView {
            Sidebar(
                credentials: credentials,
                reviewManager: reviewManager,
                appsManager: appsManager,
                showCredentialsScreen: $showCredentialsScreen,
                showSuggestionsScreen: $showSuggestionsScreen,
                selectedReview: $selectedReview
            )
            
            Color.clear
            
               
            if showCredentialsScreen || showSuggestionsScreen {
                Text("")
                    .toolbar(content: { ToolbarItem(content: {Text("")}) })
            } else {
                FullReviewSide(review: $selectedReview)
                .environmentObject(appsManager)
                .environmentObject(reviewManager)
            }
//            .frame(width: showCredentialsScreen ? 0 : 200)
            
        }
        .onChange(of: reviewManager.retrievedReviews) { newValue in
            selectedReview = nil
        }
        .onChange(of: credentials.savedInKeychain) { saved in
            if saved {
                Task {
                    await appsManager.getAppsTwan()
                }
            }
        }
    }
}

struct FullAppView_Previews: PreviewProvider {
    static var previews: some View {
        FullAppView()
    }
}
