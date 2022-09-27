//
//  FullReviewSide.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 21/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct FullReviewSide: View {
    
    @Binding var review: CustomerReview?
    @FocusState private var isReplyFocused: Bool
    @State private var showReplyField = false
    @StateObject private var translator = DeepL()
    @EnvironmentObject var reviewManager: ReviewManager
    @EnvironmentObject var appsManager: AppsManager
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    @State private var isReplying = false
    @State private var succesfullyReplied = false
    
    @State private var error : NSError?  = nil
    
    @State private var replyText = ""
    @State private var hoveringOnSuggestion: Suggestion?
    @State private var showTranslate = false
    @State private var showTranslation = false
    @State private var hoveringBody = false
    
    
    var translateString : String {
        "https://translate.google.com/?sl=auto&tl=en&text=\(review?.attributes?.title ?? "")\n\(review?.attributes?.body ?? "")&op=translate"
    }
    
    
    var body: some View {
        VStack {
            ZStack {
                Color.gray.opacity(0.1)
                
                if let review = review {
                    reviewView(review: review)
                } else {
                    VStack {
                        Text("")
                    }
                }
            }
        }
        .frame(minWidth: 500)
        .overlay(
            ZStack {
                Color(.controlBackgroundColor)
                VStack {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 60))
                        .opacity(succesfullyReplied ? 1 : 0)
                        .animation(.default, value: isReplying)
                    
                    if isReplying {
                        ProgressView()
                    }
                    
                    Text(succesfullyReplied ? "Pending Publication" : "Sending Reply...")
                        .font(.system(.title, design: .rounded))
                        .bold()
                }
            }
                .opacity(isReplying || succesfullyReplied ? 1 : 0)
        )
        //        .toolbar(content: {
        //            ToolbarItem(content: {Spacer()})
        //            ToolbarItem(placement: .automatic) {
        //                Button {
        //                    getNewReview()
        //                } label: {
        //                    Text("Skip")
        //
        //                }
        //                .help(Text("Skip to another unanswered review (⌘S)"))
        //                .opacity(review == nil ? 0 : 1)
        //                .keyboardShortcut("s", modifiers: .command)
        //            }
        //        })
        
        .onChange(of: review) { newValue in
            
            // Clean the translated strings
            translator.translatedTitle = ""
            translator.translatedBody = ""
            //            reviewManager.replyText = ""
            isReplying = false
            succesfullyReplied = false
            replyText = ""
            isReplyFocused = true
        }
        
    }
    
    
    
    func getNewReview() {
        guard let review = review else {
            return
        }
        
        guard reviewManager.retrievedReviews.firstIndex(of: review) != nil else {
            return
        }
        
        if let review = reviewManager.retrievedReviews.filter({ !pendingPublications.contains($0.id ) }).randomElement() {
            self.review = review
        } else {
            print("No new reviews available")
        }
    }
    
    func reviewView(review: CustomerReview) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    ReviewRatingView(review: review)
                    ReviewTitle(translator: translator, review: review)
                    ReviewMetadata(review: review)
                }
                
                Text(!translator.translatedBody.isEmpty ? translator.translatedBody : review.attributes?.body ?? "")
                    .font(.system(.title3, design: .rounded))
                    .textSelection(.enabled)
                    .padding(.bottom)
                
                HStack {
                    if !translator.translatedTitle.isEmpty {
                        Button {
                            translator.translatedBody = ""
                            translator.translatedTitle = ""
                        } label: {
                            Text("Show Original")
                        }
                    } else {
                        Button {
                            Task {
                                await deepLReview()
                            }
                        } label: {
                            Text("Translate Review")
                        }
                    }
                }
                
                if translator.detectedSourceLanguage != nil {
                    Text(translator.detectedSourceLanguage?.name ?? "No language found")
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            showTranslate.toggle()
                        } label: {
                            Label(showTranslate ? "Close" : "View Google Translate", systemImage: "globe")
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    if showTranslate {
                        WebView(urlString: translateString)
                            .frame(height: 500)
                            .padding(.bottom)
                    }
                    
                    if !translator.translatedReply.isEmpty {
                        Text(translator.translatedReply)
                            .textSelection(.enabled)
                    }
                    
                    ReviewReplyArea(isReplyFocused: $isReplyFocused,
                                    replyText: $replyText,
                                    hoveringOnSuggestion: $hoveringOnSuggestion,
                                    translator: translator)
                    .padding(.horizontal, -4)
                    .padding(.top, -8)
                }
                
                
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await respondToReview()
                        }
                    } label: {
                        Text("Send")
                    }
                    .disabled(replyText.isEmpty)
                    .help(Text("Send the response (⌘-Return)"))
                    .keyboardShortcut(.return, modifiers: .command)
                }
                
                if error != nil{
                    ReplyErrorView(error: $error)
                        .scaleEffect(error != nil ? 1 : 0)
                        .opacity(error != nil ? 1 : 0)
                }
                
                Divider()
                
                ReviewSuggestionsPicker(replyText: $replyText, hoveringOnSuggestion: $hoveringOnSuggestion)
                Spacer()
            }
            .padding()
        }
        .clipped()
    }
    
    
    
    private func deepLReview() async {
        translator.translate(
            title: review?.attributes?.title ?? "No title",
            body: review?.attributes?.body ?? "No body"
        )
    }
    
    private func respondToReview() async {
        guard let review = review else { return }
        
        Task {
            withAnimation {
                isReplying = true
            }
            
            do {
                let replied = try await reviewManager.replyTo(review: review, with: replyText)
                
                isReplying = false
                if replied {
                    print("replied succesfully")
                    succesfullyReplied = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.getNewReview()
                    }
                } else {
                    print("could not reply")
                    succesfullyReplied = false
                }
            } catch {
                print(error.localizedDescription)
                let errorCode = (error as NSError).description
                print(errorCode)
                withAnimation(.spring()) {
                    self.error = (error as NSError)
                }
                isReplying = false
            }
            
        }
    }
    
    
    
}




extension NSError {
    var errorString : String {
        if self.description.contains("This request is forbidden for security reasons") {
            return "This request is forbidden for security reasons"
        } else {
            return "Could not send reply. Not sure why, sorry!"
        }
    }
}
