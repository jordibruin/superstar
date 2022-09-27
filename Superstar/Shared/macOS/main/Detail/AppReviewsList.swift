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
    let searchText: String
    
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: 480), spacing: 12)
    ]
    
    @State var spacing: CGFloat = 12
    @State var padding: CGFloat = 12
    
    var body: some View {
            List {
                ForEach(reviewManager.retrievedReviews.filter { review in
                    if searchText == "" {
                        return true
                    } else {
                        return review.attributes!.body!.contains(searchText)
                    }
                }, id: \.id) { review in
                    
                        
                    if hidePending {
                        if !pendingPublications.contains(review.id) {
                            Button {
                                selectedReview = review
                            } label: {
                                DetailReviewView(review: review, selectedReview: $selectedReview)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        }
                    } else {
                        Button {
                            selectedReview = review
                        } label: {
                            DetailReviewView(review: review, selectedReview: $selectedReview)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }
            
            .padding(.horizontal, -16)
//            .padding(.vertical)
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
