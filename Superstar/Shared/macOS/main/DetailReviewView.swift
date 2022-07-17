//
//  DetailReviewView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
import Bagbutik

struct DetailReviewView: View {
    
    let review: CustomerReview
    @ObservedObject var reviewManager: ReviewManager
    
    @State var showReplyField = false
    @State var replyText = ""
    
    @FocusState private var isReplyFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
        
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        starsFor(review: review)
                            .font(.system(.title2, design: .rounded))
                        
                        Spacer()
                        
                        HStack {
                            Text(review.attributes?.territory?.flag ?? "")
                            Text(review.attributes?.reviewerNickname ?? "")
                                .opacity(0.8)
                            Text(review.attributes?.createdDate?.formatted() ?? Date().formatted())
                                .opacity(0.8)
                        }
                        .font(.system(.subheadline, design: .rounded))
                    }
                    
//                    Text("This is the title of the review")
                    Text(review.attributes?.title ?? "")
                        .font(.system(.title, design: .rounded))
                        .bold()
                }
                
//                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
                Text(review.attributes?.body ?? "")
                    .font(.system(.title, design: .rounded))
                    .padding(.vertical, 4)
                Spacer()
                
                
            
            }
            .padding()
            
            replyArea
            
        }
//        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 0)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                isReplyFocused = true
            }
        }
    }
    
    @State var selectedItem: Int = 0
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
        
    var suggestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(suggestions) { suggestion in
                    Button {
                        showReplyField = true
                        replyText = suggestion.text
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
            }
            .padding([.horizontal, .bottom])
        }
    }
    
    var replyArea: some View {
        VStack {
            HStack {
                ZStack(alignment: .bottomLeading) {

                    Color(.controlBackgroundColor)
                        .frame(height: replyText.count < 50 ? 44 : replyText.count < 110 ? 70 : 110)
                    
                    TextEditor(text: $replyText)
                        .padding(.leading, 12)
                        .padding(.trailing)
                        .padding(.vertical, 8)
                        .frame(height: replyText.count < 50 ? 44 : replyText.count < 110 ? 70 : 110)
                        .overlay(
                            TextEditor(text: .constant("Custom Reply"))
                                .opacity(0.4)
                                .padding(.leading, 12)
                                .padding(.trailing)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                                .opacity(replyText.isEmpty ? 1 : 0)
                                .frame(height: replyText.count < 50 ? 44 : replyText.count < 110 ? 70 : 110)
                        )
                        .font(.title)
//                    TextEditor(text: $replyText)
//                        .focused($isReplyFocused)
//                        .frame(maxHeight: 200)

//                        .frame(height: 200)
                    
//                    Text("Custom Reply")
//                        .font(.system(.title3, design: .rounded))
//                        .padding(.leading, 12)
//                        .opacity(0.5)
//                        .allowsHitTesting(false)
//                        .opacity(replyText.isEmpty ? 1 : 0)
                }
//                .padding(8)
                .cornerRadius(30)
//                .frame(height: replyText.count < 70 ? 32 : replyText.count < 140 ? 70 : 110)
//                .lineSpacing(10)
                .padding(.top, 8)
                
                Spacer()
                Button {
                    reviewManager.replyTo(review: review, with: replyText)
                } label: {
                    Text("REPLY")
                        .padding(8)
                        .padding(.horizontal, 6)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            
            suggestionsView
        }
        .background(Color.gray.opacity(0.2))
    }
    
    func starsFor(review: CustomerReview) -> some View {
        let realRating = review.attributes?.rating ?? 1
        
        return HStack(spacing: 2) {
            ForEach(0..<realRating, id: \.self) { star in
                Text("⭐️")
            }
            ForEach(realRating..<5, id: \.self) { star in
                Text("⭐️")
                    .opacity(0.4)
            }
        }
    }
    
}

struct DetailReviewView_Previews: PreviewProvider {
    static var previews: some View {
        DetailReviewView(
            review: CustomerReview(
                id: "",
                links: ResourceLinks(self: "")
            ),
            reviewManager: ReviewManager()
        )
    }
}

struct Suggestion: Identifiable, Codable {
    
    var title: String
    var text: String
    let appId: Int
    
    var id: String { "\(self.appId) \(self.title) \(self.text)"}
}

extension TerritoryCode {
    
    var flag: String {
        switch self {
        case .usa:
            return "🇺🇸"
        case .nld:
            return "🇳🇱"
        case .ukr:
            return "🇺🇦"
        default:
            return "🌎"
        }
    }
}

extension NSTextView {
  open override var frame: CGRect {
    didSet {
      backgroundColor = .clear
      drawsBackground = true
    }
  }
}
