//
//  FullAppView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI

struct FullAppView: View {
    
    @StateObject var reviewManager = ReviewManager()
    @StateObject var appsManager = AppsManager()
    
    @State var showCredentialsScreen = false
    @State var showSuggestionsSheet = false
    @State var showSettings = false
    
    @StateObject var credentials = CredentialsManager.shared
    
    var body: some View {
        HSplitView {
            NavigationView {
                if credentials.allCredentialsAvailable() {
                    if appsManager.foundApps.isEmpty {
                        if credentials.allCredentialsAvailable() {
                            VStack {
                                ProgressView()
                                Text("Loading Apps")
                            }
                        } else {
                            
                        }
                    } else {
                        List {
                            ForEach(appsManager.foundApps, id: \.id) { app in
                                NavigationLink {
                                    AppDetailView(
                                        appsManager: appsManager,
                                        reviewManager: reviewManager,
                                        app: app
                                    )
                                } label: {
                                    HStack {
                                        AsyncImage(url: appsManager.imageURL(for: app), scale: 2) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                                .clipped()
                                        } placeholder: {
                                            Color.clear
                                        }
                                        .frame(width: 32, height: 32)
                                        Text(app.attributes?.name ?? "No Name")
                                    }
                                }
                            }
                        }
                        .overlay(
                            VStack {
                                Spacer()
                                
                                VStack {
                                    ProgressView()
                                    Text("Loading Icons")
                                        .font(.system(.title2, design: .rounded))
                                        .bold()
                                }
                                .padding(12)
                                .frame(width: 120)
                                .background(.thinMaterial)
                                .cornerRadius(12)
                            }
                            .opacity(appsManager.loadingIcons ? 1 : 0)
                        )
                        .listStyle(.sidebar)
                    }
                } else {
                    Text("Add credentials")
                }
                
                EmptyStateView(showCredentialsScreen: $showCredentialsScreen)
            }
            .toolbar(content: {
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSuggestionsSheet = true
                    } label: {
                        Text("Suggestions")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        showCredentialsScreen.toggle()
                    } label: {
                        Image(systemName: "key.fill")
                    }
                }
                
                ToolbarItem(placement: .automatic) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            })
            .sheet(isPresented: $showCredentialsScreen, content: {
                AddCredentialsView()
            })
            .sheet(isPresented: $showSuggestionsSheet, content: {
                SuggestionsConfigView(showSheet: $showSuggestionsSheet)
            })
            .sheet(isPresented: $showSettings, content: {
                SettingsSheet(appsManager: appsManager)
            })
            .onChange(of: credentials.allCredentialsAvailable()) { available in
                if available {
                    Task {
                        await appsManager.getApps()
                    }
                }
            }
            
        }
    }
}

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
                
                Button {
                    credentials.updatedCredentials = UUID()
                } label: {
                    Text("Reload")
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
