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
    @State var replyText = ""
    @FocusState private var isReplyFocused: Bool
    @State var showReplyField = false
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    
    var body: some View {
        VStack {
            ZStack {
                Color.gray.opacity(0.1)
                
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading) {
                        starsFor(review: review)
                        HStack {
                            Text(review.attributes?.title ?? "")
                                .font(.system(.title3, design: .rounded))
                                .bold()
                            
                            Spacer()
                        }
                    }
                    
                    Text(review.attributes?.body ?? "")
                        .font(.system(.body, design: .rounded))
                 
                    metadata
                    
                    suggestionsPicker
                    
                    replyArea
                    Spacer()
                }
                .padding(.top)
                .frame(width: 280)
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
                    .font(.title2)
            }
            ForEach(realRating..<5, id: \.self) { star in
                Image(systemName: "star")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
        }
    }
    
    var suggestionsPicker: some View {
        Menu {
            ForEach(suggestions) {  suggestion in
                Button {
                    replyText = suggestion.text
                    
//                    if autoReply {
//                        print("we should automatically sent it now")
//                        Task {
//                            await respondToReview()
//                        }
//                    } else {
                        showReplyField = true
//                    }
                } label: {
                    Text(suggestion.title.capitalized)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        } label: {
            Text("Suggestions")
        }
        .menuStyle(.borderlessButton)
        .frame(width: 110)
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.secondary.opacity(0.1)))
    }
    
    var metadata: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text(review.attributes?.territory?.flag ?? "")
                Text(review.attributes?.reviewerNickname ?? "")
                    .opacity(0.8)
            }
            Text(review.attributes?.createdDate?.formatted() ?? Date().formatted())
                .opacity(0.8)
        }
        .font(.system(.subheadline, design: .rounded))
    }
    
    var replyArea: some View {

        ZStack(alignment: .topLeading) {
            Color(.controlBackgroundColor)
                .frame(height: 200)
            
            TextEditor(text: $replyText)
                .focused($isReplyFocused)
//                .padding(8)
                .frame(height: replyText.count < 30 ? 44 : replyText.count < 110 ? 70 : 110)
                .overlay(
                    TextEditor(text: .constant("Custom Reply"))
                        .opacity(0.4)
//                        .padding(8)
                        .allowsHitTesting(false)
                        .opacity(replyText.isEmpty ? 1 : 0)
                        .frame(height: 200)
                )
        }
        .padding(8)
        .cornerRadius(8)
    }
}

struct FullReviewSide_Previews: PreviewProvider {
    static var previews: some View {
        FullReviewSide(review: CustomerReview(id: "", links: ResourceLinks(self: "")))
    }
}
