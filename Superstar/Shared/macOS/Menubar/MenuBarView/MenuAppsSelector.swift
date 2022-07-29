//
//  MenuAppsSelector.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI

struct MenuAppsSelector: View {
    
    @Binding var showAppPicker: Bool
    
    @ObservedObject var reviewManager: ReviewManager
    @ObservedObject var appsManager: AppsManager
    
    var body: some View {
        ZStack {
            Color(.controlBackgroundColor)
            VStack {
                header
                
                if appsManager.foundApps.isEmpty {
                    VStack {
                        Spacer()
                        VStack {
                            ProgressView()
                                .scaleEffect(0.5)
                            
                            Text("Loading apps")
                                .font(.system(.body, design: .rounded))
                                .bold()
                        }
                        Spacer()
                    }
                } else {
                    ScrollView {
                        appsList
                    }
                }
            }
            .padding(8)
        }
    }
    
    var header: some View {
        HStack {
            Text("Apps")
                .font(.system(.title3, design: .rounded))
                .bold()
            
            Spacer()
            Button {
                showAppPicker = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }
    
    @AppStorage("selectedSortOrder") var selectedSortOrder: ReviewSortOrder = .dateDescending
    
    var appsList: some View {
        VStack(alignment: .leading) {
            ForEach(appsManager.foundApps, id: \.id) { app in
                Button {
                    showAppPicker = false
                    Task {
                        appsManager.makeActive(app: app)
                        await reviewManager.getReviewsFor(id: app.id, sort: selectedSortOrder)
                    }
                } label: {
                    HStack {
                        if let url = appsManager.imageURL(for: app) {
                            CacheAsyncImage(url: url, scale: 2) { phase in
                                switch phase {
                                case .success(let image):
                                    
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
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
                            .frame(width: 44, height: 44)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.orange)
                                .frame(width: 44, height: 44)
                        }
                        Text(app.attributes?.name ?? "No Name")
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct MenuAppsSelector_Previews: PreviewProvider {
    static var previews: some View {
        MenuAppsSelector(
            showAppPicker: .constant(false),
            reviewManager: ReviewManager(),
            appsManager: AppsManager()
        )
    }
}
