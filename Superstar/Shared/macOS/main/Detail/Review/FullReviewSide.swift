//
//  FullReviewSide.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI
import Bagbutik

struct FullReviewSide: View {
    
    let review: CustomerReview
    
    var body: some View {
        VStack {
            ZStack {
                Color.gray.opacity(0.1)
//                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: -3, y: 0)
                
                VStack(alignment: .leading) {
                    starsFor(review: review)
                    HStack {
                        Text(review.attributes?.title ?? "")
                            .font(.system(.title3, design: .rounded))
                            .bold()
                        
                        Spacer()
                    }
                    
                    Text(review.attributes?.body ?? "")
                        .font(.system(.body, design: .rounded))
                    Spacer()
                }
                .frame(width: 220)
            }
        }
        .frame(width: 280)
        
    }
    
    func starsFor(review: CustomerReview) -> some View {
        let realRating = review.attributes?.rating ?? 1
        
        return HStack(spacing: 2) {
            ForEach(0..<realRating, id: \.self) { star in
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
            ForEach(realRating..<5, id: \.self) { star in
                Image(systemName: "star")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
        }
    }
}

struct FullReviewSide_Previews: PreviewProvider {
    static var previews: some View {
        FullReviewSide(review: CustomerReview(id: "", links: ResourceLinks(self: "")))
    }
}
