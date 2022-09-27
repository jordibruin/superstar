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
    @EnvironmentObject var settingsManager: SettingsManager
    
    @State var showSettings = false
    @Binding var showCredentialsScreen: Bool
    @Binding var showSuggestionsScreen: Bool
    
    @State var showHomeScreen = false
    
    @Binding var selectedReview: CustomerReview?
    
    @AppStorage("hiddenAppIds") var hiddenAppIds: [String] = []
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    @EnvironmentObject var iapManager: IAPManager
    
    var body: some View {
        List {
            settingsSection
            appsSection
            
            if !appsManager.foundApps.isEmpty && !hiddenAppIds.isEmpty {
                hiddenApps
            }
        }
        .listStyle(.sidebar)
        .frame(width: 260)
        .toolbar(content: { ToolbarItem(content: {Text("")}) })

        .onChange(of: appsManager.foundApps, perform: { foundApps in
            if foundApps.firstIndex(where: { $0.id == favoriteAppId} ) != nil {
                showFavoriteApp = true
                appsManager.selectedAppId = favoriteAppId
            }
        })
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
    }
 
    var settingsSection: some View {
        Section {
            ForEach(SettingsPage.allCases) { page in
                Button {
//                    print("We should open something")
                    settingsManager.selectedPage = page
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                } label: {
                    page.label
                        .font(.title3)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
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
            HStack {
                Text("Apps")
                Spacer()
                Button {
                    appsManager.foundApps = []
                    Task {
                        await appsManager.getAppsTwan()
                    }
                } label: {
                    Text("Reload")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @State var showFavoriteApp = false
    
    @AppStorage("favoriteAppId") var favoriteAppId: String = ""
    
    var appsList: some View {
        ForEach(appsManager.foundApps, id: \.id) { app in
            if !hiddenAppIds.contains(app.id) {
                NavigationLink(tag: app.id, selection: $appsManager.selectedAppId) {
                    AppDetailView(
                        app: app,
                        selectedReview: $selectedReview
                    )
                    .environmentObject(appsManager)
                    .environmentObject(reviewManager)
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
                                .foregroundColor(.orange)
                                .frame(width: 32, height: 32)
                        }
                        Text(app.attributes?.name ?? "No Name")
                    }
                }
//                .disabled(iapManager.proUser ? false : iapManager.freeAppId == app.id ? false : true)
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
    
    var hiddenApps: some View {
        Section {
            ForEach(appsManager.foundApps, id: \.id) { app in
                if hiddenAppIds.contains(app.id) {
                    NavigationLink(tag: app.id, selection: $appsManager.selectedAppId) {
                        AppDetailView(
                            app: app,
                            selectedReview: $selectedReview
                        )
                        .environmentObject(appsManager)
                        .environmentObject(reviewManager)
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
                                    .foregroundColor(.orange)
                                    .frame(width: 32, height: 32)
                            }
                            Text(app.attributes?.name ?? "No Name")
                        }
                    }
//                    .disabled(iapManager.proUser ? false : iapManager.freeAppId == app.id ? false : true)
                    .contextMenu {
                        Button {
                            hiddenAppIds.append(app.id)
                        } label: {
                            Text("Hide")
                        }
                    }
                }
            }
        } header: {
            Text("Hidden Apps")
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

