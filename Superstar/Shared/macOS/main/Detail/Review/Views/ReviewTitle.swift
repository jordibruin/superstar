//
//  ReviewTitle.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct ReviewTitle: View {
    @ObservedObject var translator : DeepL
    let review : CustomerReview
    
    var body: some View {
        Text(!translator.translatedTitle.isEmpty ? translator.translatedTitle : review.attributes?.title ?? "")
            .font(.system(.title2, design: .rounded).weight(.bold))
            .textSelection(.enabled)
    }
}
