//
//  MenuBarHeader.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct MenuBarHeader: View {
    
    @Binding var showAppPicker: Bool
    
    @ObservedObject var appsManager: AppsManager
    @ObservedObject var reviewManager: ReviewManager
    
    @Binding var review: CustomerReview?
    
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    var body: some View {
        HStack {
            if let url = appsManager.imageURL(for: appsManager.selectedApp) {
                CacheAsyncImage(url: url, scale: 2) { phase in
                    switch phase {
                    case .success(let image):
                        
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
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
                .frame(width: 28, height: 28)
     
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.orange)
                    .frame(width: 28, height: 28)
            }
            
//            Text(appsManager.selectedApp.attributes?.name ?? "")
//                .font(.system(.body, design: .rounded))
//                .bold()
            Spacer()
            
            Button {
                getNewRandomReview()
            } label: {
                Text("Skip")
            }
            
            Button {
                showAppPicker = true
            } label: {
                Text("Apps")
                    .font(.system(.body, design: .rounded))
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(.controlBackgroundColor))
    }
    
    func getNewRandomReview() {
        if let review = reviewManager.retrievedReviews.randomElement() {
            
            if !pendingPublications.contains(review.id) {
                self.review = review
            } else {
                getNewRandomReview()
            }
        }
    }
}

struct MenuBarHeader_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarHeader(
            showAppPicker: .constant(false),
            appsManager: AppsManager(),
            reviewManager: ReviewManager(),
            review: .constant(nil)
        )
        .frame(width: 250)
    }
}
