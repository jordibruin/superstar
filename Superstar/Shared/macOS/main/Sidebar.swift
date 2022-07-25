//
//  Sidebar.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 25/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct Sidebar: View {
    
    @ObservedObject var credentials: CredentialsManager
    @ObservedObject var reviewManager: ReviewManager
    @ObservedObject var appsManager: AppsManager
    
    @State var showSettings = false
    @Binding var showCredentialsScreen: Bool
    @Binding var showSuggestionsScreen: Bool
    
    @State var showHomeScreen = false
    
    @Binding var selectedReview: CustomerReview?
    
    @AppStorage("hiddenAppIds") var hiddenAppIds: [String] = []
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    
    @State var autoReply = false
    
    var body: some View {
        List {
            settingsSection
            appsSection
        }
        .listStyle(.sidebar)
        .frame(width: 260)
        .toolbar(content: { ToolbarItem(content: {Text("")}) })
        .onChange(of: showCredentialsScreen ) { newValue in
            if newValue {
                selectedReview = nil
            }
        }
        .onChange(of: showSuggestionsScreen ) { newValue in
            if newValue {
                selectedReview = nil
            }
        }
        .sheet(isPresented: $showSettings, content: {
            SettingsSheet(appsManager: appsManager)
        })
    }
    
    var settingsSection: some View {
        Section {
            NavigationLink(isActive: $showHomeScreen) {
                EmptyStateView(
                    showCredentialsScreen: $showCredentialsScreen
                )
            } label: {
                Label("Home", systemImage: "house.fill")
            }
            
            Button {
                showSettings = true
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .buttonStyle(.plain)
            
            NavigationLink(isActive: $showCredentialsScreen) {
                AddCredentialsView()
            } label: {
                Label("Credentials", systemImage: "key.fill")
            }

            NavigationLink(isActive: $showSuggestionsScreen) {
                SuggestionsConfigView(showSheet: .constant(true))
            } label: {
                Label("Suggestions", systemImage: "star.bubble")
            }
        } header: {
            Text("Settings")
            
        }
    }
    
    var appsSection: some View {
        Section {
            if credentials.allCredentialsAvailable() {
                if appsManager.foundApps.isEmpty {
                    loadingApps
                } else {
                    appsList
                }
            }
        } header: {
            Text("Apps")
        }
    }
    
    var appsList: some View {
        ForEach(appsManager.foundApps, id: \.id) { app in
            if !hiddenAppIds.contains(app.id) {
                NavigationLink {
                    AppDetailView(
                        appsManager: appsManager,
                        reviewManager: reviewManager,
                        app: app,
                        autoReply: $autoReply,
                        selectedReview: $selectedReview
                    )
                } label: {
                    HStack {
                        if let url = appsManager.imageURL(for: app) {
                            CacheAsyncImage(url: url, scale: 2) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 9))
                                        .clipped()
                                case .failure(let _):
                                    Text("E")
                                case .empty:
                                    Color.gray.opacity(0.05)
                                @unknown default:
                                    // AsyncImagePhase is not marked as @frozen.
                                    // We need to support new cases in the future.
                                    Image(systemName: "questionmark")
                                }
                            }
                            .frame(width: 32, height: 32)
                        } else {
                            RoundedRectangle(cornerRadius: 7)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                        }
                        Text(app.attributes?.name ?? "No Name")
                    }
                }
                .contextMenu {
                    Button {
                        hiddenAppIds.append(app.id)
                    } label: {
                        Text("Hide")
                    }
                }
            }
        }
        
    }
    
    var loadingApps: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack {
                    ProgressView()
                        .scaleEffect(0.5)
                    Text("Loading Apps")
                }
                Spacer()
            }
            Spacer()
        }
    }
}

//struct Sidebar_Previews: PreviewProvider {
//    static var previews: some View {
//        Sidebar(
//    }
//}
