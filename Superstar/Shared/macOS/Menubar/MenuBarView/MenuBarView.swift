//
//  MenuBarView.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI
import Bagbutik

struct MenuBarView: View {
    
    @StateObject var reviewManager = ReviewManager()
    @StateObject var appsManager = AppsManager()
    @StateObject var credentials = CredentialsManager.shared
    
    @State var review: CustomerReview?
    @State var selectedItem: Int = 0
    @State var showAppPicker = false
    
    var body: some View {
        VStack {
            MenuBarHeader(
                showAppPicker: $showAppPicker,
                appsManager: appsManager,
                reviewManager: reviewManager,
                review: $review
            )
            
            if let review = review {
                MenuBarReview(
                    reviewManager: reviewManager,
                    appsManager: appsManager,
                    review: review
                )
            } else {
                Spacer()
                VStack {
                    ProgressView()
                        .scaleEffect(0.5)
                    Text("Loading reviews")
                        .font(.system(.body, design: .rounded))
                }
                Spacer()
            }
        }
        .frame(width: 300, height: 350)
        .overlay(
            MenuAppsSelector(
                showAppPicker: $showAppPicker,
                reviewManager: reviewManager,
                appsManager: appsManager
            )
            .opacity(showAppPicker ? 1 : 0)
        )
        .overlay(
            VStack {
                Text("Add your App Store Connect credentials in the main app")
            }
                .opacity(credentials.allCredentialsAvailable() ? 0 : 1)
        )
        .onAppear {
            if appsManager.selectedApp.id == "Placeholder" {
                showAppPicker = true
            }
        }
        .onChange(of: reviewManager.retrievedReviews, perform: { reviews in
            if let review = reviews.randomElement() {
                self.review = review
            }
        })
    }
    
    
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarView()
    }
}
