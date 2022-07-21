//
//  MenuBarHeader.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI
import Bagbutik

struct MenuBarHeader: View {
    
    @Binding var showAppPicker: Bool
    
    @ObservedObject var appsManager: AppsManager
    @ObservedObject var reviewManager: ReviewManager
    
    @Binding var review: CustomerReview?
    
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    var body: some View {
        HStack {
            if let url = appsManager.imageURL(for: appsManager.selectedApp) {
                AsyncImage(url: url, scale: 2) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .clipped()
                } placeholder: {
                    Color.clear
                }
                .frame(width: 28, height: 28)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.blue)
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
