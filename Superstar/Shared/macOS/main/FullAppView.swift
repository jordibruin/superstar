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
                sidebar
                EmptyStateView(showCredentialsScreen: $showCredentialsScreen)
            }
            .toolbar(content: { toolbarItems })
            .sheet(isPresented: $showCredentialsScreen, content: {
                AddCredentialsView()
            })
            .sheet(isPresented: $showSuggestionsSheet, content: {
                SuggestionsConfigView(showSheet: $showSuggestionsSheet)
            })
            .sheet(isPresented: $showSettings, content: {
                SettingsSheet(appsManager: appsManager)
            })
            .onAppear {
            }
            .onChange(of: credentials.allCredentialsAvailable()) { available in
                if available {
                    Task {
                        await appsManager.getApps()
                    }
                }
            }
        }
    }
    
    @State var autoReply = false
    @State var selectMultiple = false
    @State var selectedRatings: [Int] = [1,2,3,4,5]
    
    
    var toolbarItems: some ToolbarContent {
        Group {
            
            ToolbarItem(placement: .automatic) {
                Menu {
                    ForEach(1..<6, id: \.self) { index in
                        Button {
                            if let index = selectedRatings.firstIndex(of: index) {
                                selectedRatings.remove(at: index)
                            } else {
                                selectedRatings.append(index)
                            }
                        } label: {
                            Label("\(index) star\(index > 1 ? "s" : "")", systemImage: "checkmark")
                            
                            //                            HStack {
                            //                                Text("\(index) star\(index > 1 ? "s" : "")")
                            //
                            //                                if selectedRatings.contains(index) {
                            //                                    Image(systemName: "checkmark")
                            //                                }
                            //                            }
                        }
                        
                    }
                } label: {
                    Text("Sort")
                }
            }
            
            //            ToolbarItem(placement: .automatic) {
            //                Toggle(isOn: $selectMultiple) {
            //                    Text("Multi-Select")
            //                }
            //            }
            
            ToolbarItem(placement: .automatic) {
                Toggle(isOn: $autoReply) {
                    Text("Auto Reply")
                }
            }
            
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
        }
    }
    
    var sidebar: some View {
        Group {
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
//                        Section {
//                            Button {
//                                Task {
//                                    await appsManager.getIcons()
//                                }
//                            } label: {
//                                Text("Load Icons")
//                            }
//                            
//                        } header: {
//                            Text("Settings")
//                        }
                        
                        Section {
                            ForEach(appsManager.foundApps, id: \.id) { app in
                                NavigationLink {
                                    AppDetailView(
                                        appsManager: appsManager,
                                        reviewManager: reviewManager,
                                        app: app,
                                        selectMultiple: $selectMultiple,
                                        autoReply: $autoReply
                                    )
                                } label: {
                                    HStack {
                                        if let url = appsManager.imageURL(for: app) {
                                            AsyncImage(url: url, scale: 2) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                    .clipped()
                                            } placeholder: {
                                                Color.clear
                                            }
                                            .frame(width: 32, height: 32)
                                        } else {
                                            RoundedRectangle(cornerRadius: 5)
                                                .foregroundColor(.blue)
                                                .frame(width: 32, height: 32)
                                        }
                                        Text(app.attributes?.name ?? "No Name")
                                    }
                                }
                            }
                        } header: {
                            Text("Apps")
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
        }
    }
}



struct FullAppView_Previews: PreviewProvider {
    static var previews: some View {
        FullAppView()
    }
}
