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
    @EnvironmentObject var appsManager: AppsManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State var showCredentialsScreen = false
    @State var showSuggestionsScreen = false

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
            
            EmptyStateView()
//                .toolbar(content: { toolbarItems })
            
               
            if showCredentialsScreen || showSuggestionsScreen {
                Text("test")
                    .toolbar(content: { ToolbarItem(content: {Text("")}) })
            } else {
                FullReviewSide(review: $selectedReview)
                .environmentObject(appsManager)
                .environmentObject(reviewManager)
            }
        }
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                fadeOut = true
            }
        })
//        .onChange(of: reviewManager.retrievedReviews) { newValue in
//            selectedReview = nil
//        }
        .onChange(of: appsManager.selectedAppId) { newValue in
            selectedReview = nil
        }
        .overlay(
            introScreen
        )
        .onChange(of: credentials.savedInKeychain) { saved in
            if saved {
                Task {
                    await appsManager.getAppsTwan()
                }
            }
        }
    }
    
    
    @State var fadeOut = false
    
    var introScreen: some View {
        ZStack {
            LinearGradient(
                colors: [Color.yellow, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "star.fill")
                .font(.system(size: 150))
                .foregroundColor(.white)
                .opacity(fadeOut ? 0 : 1)
                .scaleEffect(fadeOut ? 5 : 1)
                .animation(.easeOut(duration: 0.3), value: fadeOut)
        }
        .edgesIgnoringSafeArea(.top)
        .opacity(fadeOut ? 0 : 1)
        .animation(.easeOut(duration: 0.3).delay(0.5), value: fadeOut)
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(content: {Spacer()})
            
            ToolbarItem(placement: .automatic) {
                Button {
                    settingsManager.selectedPage = .suggestions
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                } label: {
                    SettingsPage.suggestions.label.labelStyle(.iconOnly)
                }
            }

            ToolbarItem(content: {
                Button {
                    settingsManager.selectedPage = .credentials
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                } label: {
                    SettingsPage.credentials.label.labelStyle(.iconOnly)
                }
            })

            ToolbarItem(content: {
                Button {
                    settingsManager.selectedPage = .settings
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                } label: {
                    SettingsPage.settings.label.labelStyle(.iconOnly)
                }
            })
        }
    }
}

struct FullAppView_Previews: PreviewProvider {
    static var previews: some View {
        FullAppView()
    }
}
