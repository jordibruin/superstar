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
    
    var appsList: some View {
        VStack(alignment: .leading) {
            ForEach(appsManager.foundApps, id: \.id) { app in
                Button {
                    showAppPicker = false
                    Task {
                        appsManager.makeActive(app: app)
                        await reviewManager.getReviewsFor(id: app.id)
                    }
                } label: {
                    HStack {
                        if let url = appsManager.imageURL(for: app) {
                            AsyncImage(url: url, scale: 2) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .clipped()
                            } placeholder: {
                                Color.clear
                            }
                            .frame(width: 44, height: 44)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.blue)
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
