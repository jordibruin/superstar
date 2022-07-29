//
//  AppReviewsList.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 27/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppReviewsList: View {
    
    @ObservedObject var reviewManager: ReviewManager
    
    let hidePending: Bool
    @Binding var selectedReview: CustomerReview?
    
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: 480), spacing: 20)
    ]
    
    var body: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 12
        ) {
            ForEach(reviewManager.retrievedReviews, id: \.id) { review in
                if hidePending {
                    if !pendingPublications.contains(review.id) {
                        Button {
                            selectedReview = review
                        } label: {
                            DetailReviewView(review: review, selectedReview: $selectedReview)
//                            DetailReviewView(
//                                review: review,
//                                reviewManager: reviewManager,
//                                selectedReview: $selectedReview
//                            )
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Button {
                        selectedReview = review
                    } label: {
                        DetailReviewView(review: review, selectedReview: $selectedReview)
//                        DetailReviewView(
//                            review: review,
//                            reviewManager: reviewManager,
//                            
//                            selectedReview: $selectedReview
//                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .padding(.vertical)
        .animation(.default,
            value: reviewManager.retrievedReviews
        )
        .id(UUID())
    }
     
}

struct AppReviewsList_Previews: PreviewProvider {
    static var previews: some View {
        AppReviewsList(
            reviewManager: ReviewManager(),
            hidePending: false,
            selectedReview: .constant(nil)
        )
    }
}
