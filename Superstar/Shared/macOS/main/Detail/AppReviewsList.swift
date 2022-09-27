//
//  AppReviewsList.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 27/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppReviewsList: View {
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    @ObservedObject var reviewManager: ReviewManager
    
    let hidePending: Bool
    @Binding var selectedReview: CustomerReview?
    let searchText: String
    
    @State private var spacing: CGFloat = 12
    @State private var padding: CGFloat = 12
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: 480), spacing: 12)
    ]
    
    
    var reviews : [CustomerReview] {
        var allReviews = reviewManager.retrievedReviews
        
        if searchText.isEmpty == false {
            allReviews = allReviews.filter { $0.attributes?.body?.contains(searchText) ?? false }
        }
        
        if hidePending {
            allReviews = allReviews.filter { !pendingPublications.contains($0.id) }
        }
        
        return allReviews
    }
    
    var body: some View {
        List {
            ForEach(reviews, id: \.id) { review in
                Button {
                    selectedReview = review
                } label: {
                    DetailReviewView(review: review, selectedReview: $selectedReview)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, -16)
        .padding(.vertical)
        .animation(.default,value: reviewManager.retrievedReviews)
        .id(UUID())
    }
    
}

struct AppReviewsList_Previews: PreviewProvider {
    static var previews: some View {
        AppReviewsList(
            reviewManager: ReviewManager(),
            hidePending: false,
            selectedReview: .constant(nil),
            searchText: ""
        )
    }
}
