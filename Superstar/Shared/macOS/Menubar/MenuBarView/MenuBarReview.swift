//
//  MenuBarReview.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct MenuBarReview: View {
    
    @ObservedObject var reviewManager: ReviewManager
    @ObservedObject var appsManager: AppsManager
    
    let review: CustomerReview
    
    @FocusState private var isReplyFocused: Bool
    
    @State var showReplyField = false
    @State var replyText = ""
    @State var isReplying = false
    @State var succesfullyReplied = false
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    var getNewReview: () -> ()
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            
            ScrollView {
                Text(review.attributes?.body ?? "")
                    .font(.system(.body, design: .rounded))
                    .padding(.bottom)
                    .minimumScaleFactor(0.7)
                    .textSelection(.enabled)
            }
            Spacer()
            suggestionsAndReply
        }
        .padding([.top, .horizontal], 8)
        .padding(.bottom, 8)
        .onAppear {
            print("APPEAR")
        }
        
        
        if showReplyField {
            replyArea
        }
    }
    
    var suggestionsAndReply: some View {
        HStack {
            suggestionsPicker
            
            Spacer()
            
            if !showReplyField {
                Button {
                    showReplyField = true
                    isReplyFocused = true
                } label: {
                    Label("Reply", systemImage: "arrowshape.turn.up.left.fill")
                    
                }
            } else {
                
                Button {
                    showReplyField = false
                    replyText = ""
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    Task {
                        await respondToReview()
                    }
                } label: {
                    Text("Send")
                }
                .disabled(replyText.isEmpty)
            }
        }
    }
    
    func respondToReview() async {
        Task {
            isReplying = true
            do {
                let replied = try  await reviewManager.replyTo(review: review, with: replyText)
                
                isReplying = false
                if replied {
                    print("replied succesfully")
                    succesfullyReplied = true
                    //                getNewRandomReview()
                    getNewReview()
                    replyText = ""
                    showReplyField = false
                    
                } else {
                    print("could not reply")
                    succesfullyReplied = false
                }
            } catch {
                print(error.localizedDescription)
            }
            
        }
    }
    
    var suggestionsPicker: some View {
        Menu {
            ForEach(suggestions) {  suggestion in
                Button {
                    replyText = suggestion.text
                    showReplyField = true
                } label: {
                    Text(suggestion.title.capitalized)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        } label: {
            Text("Suggestions")
        }
        .menuStyle(.borderlessButton)
        .frame(width: 120)
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.secondary.opacity(0.1)))
    }
    
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    ReviewRatingView(review: review)
                        .font(.system(showReplyField ? .body :.body, design: .rounded))
                    Spacer()
                    metadata
                }
                
                Text(review.attributes?.title ?? "")
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .padding(.leading, 2)
            }
            
        }
    }
    
    var metadata: some View {
        VStack(alignment: .trailing) {
            HStack {
                Text(review.attributes?.territory?.flag ?? "")
                Text(review.attributes?.reviewerNickname ?? "")
                    .opacity(0.8)
            }
        }
        .font(.system(.subheadline, design: .rounded))
    }
    
    var replyArea: some View {
        VStack {
            HStack {
                ZStack(alignment: .bottomLeading) {
                    Color(.controlBackgroundColor)
                        .frame(height: replyText.count < 30 ? 44 : replyText.count < 100 ? 70 : 110)
                    
                    TextEditor(text: $replyText)
                        .focused($isReplyFocused)
                        .padding(.leading, 12)
                        .padding(.trailing)
                        .padding(.vertical, 8)
                        .frame(height: replyText.count < 30 ? 44 : replyText.count < 100 ? 70 : 110)
                        .overlay(
                            TextEditor(text: .constant("Custom Reply"))
                                .opacity(0.4)
                                .padding(.leading, 12)
                                .padding(.trailing)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                                .opacity(replyText.isEmpty ? 1 : 0)
                                .frame(height: replyText.count < 30 ? 44 : replyText.count < 110 ? 70 : 110)
                        )
                        .font(.title3)
                }
//                .cornerRadius(8)
            }
//            .padding(10)
        }
        .background(Color.gray.opacity(0.2))
    }
}

struct MenuBarReview_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarReview(reviewManager: ReviewManager(), appsManager: AppsManager(), review: .init(type: .customerReviews, id: "", links: .init(this: ""))) {
            
        }
    }
}
