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
    @Binding var selectMultiple: Bool
    @FocusState private var isReplyFocused: Bool
    
    @State var selectedInMultiple = false
    
    @State var succesfullyReplied = false
    @State var selectedItem: Int = 0
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    
    @State var isReplying = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                header

                ScrollView {
                    Text(review.attributes?.body ?? "")
                        .font(.system(showReplyField ? .body : .title2, design: .rounded))
                        .padding(.bottom)
                        .minimumScaleFactor(0.7)
                }
                Spacer()
                suggestionsAndReply
            }
            .padding([.top, .horizontal])
            .padding(.bottom, showReplyField ? 4 : 20)

            if showReplyField {
                replyArea
            }
//            Button {
//
//            } label: {
//                Text("Tappp")
//            }

        }
        .frame(height: 300)
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
                    
                    Text(isReplying ? "Sending Reply..." : "Reply sent")
                        .font(.system(.title, design: .rounded))
                        .bold()
                }
            }
            .opacity(isReplying || succesfullyReplied ? 1 : 0)
        )
        .background(Color(.controlBackgroundColor))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 0)
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
                        isReplying = true
                        let replied = await reviewManager.replyTo(review: review, with: replyText)
                        
                        isReplying = false
                        if replied {
                            print("replied succesfully")
                            succesfullyReplied = true
                        } else {
                            print("could not reply")
                            succesfullyReplied = false
                        }
                    }
                } label: {
                    Text("Send")
                }
                .disabled(replyText.isEmpty)
            }
        }
    }
    
    var suggestionsPicker: some View {
        Menu {
            ForEach(suggestions) {  suggestion in
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
        } label: {
            Text("Suggestions")
        }
        .menuStyle(.borderlessButton)
        .frame(width: 110)
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.secondary.opacity(0.1)))
    }
    
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if selectMultiple {
                        multipleSelector
                    }
                    starsFor(review: review)
                        .font(.system(showReplyField ? .body :.title3, design: .rounded))
                    Spacer()
                    metadata
                }
                
                Text(review.attributes?.title ?? "")
                    .font(.system(showReplyField ? .body : .title2, design: .rounded))
                    .bold()
                    .padding(.leading, 2)
            }
            
        }
    }
    
    var multipleSelector: some View {
        Button {
            selectedInMultiple.toggle()
        } label: {
            Image(systemName: selectedInMultiple ? "circle.fill" : "circle")
                .foregroundColor(.blue)
                .font(.title2)
        }
        .buttonStyle(.plain)
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
        VStack {
            HStack {
                ZStack(alignment: .bottomLeading) {
                    Color(.controlBackgroundColor)
                        .frame(height: replyText.count < 50 ? 44 : replyText.count < 110 ? 70 : 110)
                    
                    TextEditor(text: $replyText)
                        .focused($isReplyFocused)
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
                        .font(.title3)
                }
                .cornerRadius(8)
            }
            .padding(10)
        }
        .background(Color.gray.opacity(0.2))
    }
    
    func starsFor(review: CustomerReview) -> some View {
        let realRating = review.attributes?.rating ?? 1
        
        return HStack(spacing: 2) {
            ForEach(0..<realRating, id: \.self) { star in
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
            }
            ForEach(realRating..<5, id: \.self) { star in
                Image(systemName: "star")
                    .foregroundColor(.orange)
            }
        }
    }
    
}

//struct DetailReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailReviewView(
//            review: CustomerReview(
//                id: "",
//                links: ResourceLinks(self: "")
//            ),
//            reviewManager: ReviewManager()
//        )
//    }
//}

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
