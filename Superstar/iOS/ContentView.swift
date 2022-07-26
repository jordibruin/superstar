//
//  ContentView.swift
//  Superstar
//
//  Created by Jordi Bruin on 26/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ContentView: View {
    
    @StateObject var appsManager = AppsManager()
    @StateObject var reviewManager = ReviewManager()
    
    var body: some View {
        TabView {
            NavigationView {
                
                VStack {
                    if !appsManager.foundApps.isEmpty {
                        List {
                            ForEach(appsManager.foundApps, id: \.id) { app in
                                NavigationLink {
                                    AppDetailView(app: app, selectedReview: .constant(nil))
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
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
                                            .frame(width: 40, height: 40)
                                        } else {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.orange)
                                                .frame(width: 40, height: 40)
                                        }
                                        
                                        Text(app.attributes?.name ?? "")
                                    }
                                }

                                
                            }
                        }
                    } else {
                        Button {
                            Task {
                                await appsManager.getAppsTwan()
                            }
                        } label: {
                            Text("Get apps")
                        }
                    }
                }
                .navigationTitle("Apps")
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
                
            }
            
            VStack {
                Button {
                    //                    CredentialsManager.shared.
                    CredentialsManager.shared.updateInKeychain(key: "keyId", value: "S7CCHZ24JU")
                    CredentialsManager.shared.updateInKeychain(key: "issuerId", value: "69a6de8a-5b4e-47e3-e053-5b8c7c11a4d1")
                    CredentialsManager.shared.updateInKeychain(key: "privateKey", value: "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgn73yZb+a5vth1BJeMbuZ7bqdAXV0LSyL9g7iFo4JR+OgCgYIKoZIzj0DAQehRANCAASqmFkYzcfQnKdcfVtW5xr1jBQ3JZCTIMsadbdTiUUd2KtW1Jn+UvZxjomJH/CyF+4APDZca0Hxn/mrECuDZCLb")
                } label: {
                    Text("Set credentials")
                }
                
            }
            .tabItem {
                Label("Credentials", systemImage: "key.fill")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
