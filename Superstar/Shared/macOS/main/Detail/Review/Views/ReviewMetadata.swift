//
//  ReviewMetadata.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ReviewMetadata : View {
    let review : CustomerReview
    
    var body: some View {
        HStack {
            Text(review.attributes?.territory?.flag ?? "")
            Text(review.attributes?.reviewerNickname ?? "")
                .opacity(0.8)
            
            Spacer()
            Text(review.attributes?.createdDate?.formatted(.dateTime.day().month().year()) ?? Date().formatted())
                .opacity(0.8)
        }
        .font(.system(.body, design: .rounded))
    }
}
