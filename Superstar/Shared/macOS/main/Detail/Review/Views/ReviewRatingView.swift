//
//  ReviewRatingView.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ReviewRatingView: View {
    let review : CustomerReview
    
    var realRating : Int {
        review.attributes?.rating ?? 1
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<realRating, id: \.self) { star in
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
            ForEach(realRating..<5, id: \.self) { star in
                Image(systemName: "star")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
        }
    }
}
