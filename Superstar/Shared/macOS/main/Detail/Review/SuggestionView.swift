//
//  SuggestionView.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 29/07/2022.
//

import SwiftUI

struct SuggestionView: View {
    
    @EnvironmentObject var appsManager: AppsManager
    
    let suggestion: Suggestion
    @Binding var replyText: String
    @Binding var hoveringOnSuggestion: Suggestion?
    @Binding var suggestions: [Suggestion]
    let index : Int
    
    var body: some View {
        Button {
            replyText = suggestion.text
            
            // TODO: show next review
            // TODO: auto reply
            //                    if autoReply {
            //                        print("we should automatically sent it now")
            //                        Task {
            //                            await respondToReview()
            //                        }
            //                    } else {
            //                        showReplyField = true
            //                    }
            
        } label: {
            HStack {
                appIcon
                //                        Text(appsManager.appNameFor(appId: "\(suggestion.appId)"))
                Text(suggestion.title.capitalized)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(hoveringOnSuggestion != nil && hoveringOnSuggestion! == suggestion ? Color.secondary.opacity(0.3) : Color(.controlBackgroundColor))
            .foregroundColor(.primary)
            .cornerRadius(6)
        }
        .keyboardShortcut(KeyEquivalent(Character(UnicodeScalar(index)!)), modifiers: .command)
        .onHover { hover in
            if hover {
                hoveringOnSuggestion = suggestion
            } else {
                hoveringOnSuggestion = nil
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                if let index = suggestions.firstIndex(of: suggestion) {
                    suggestions.remove(at: index)
                }
            } label: {
                Text("Remove Suggestion")
            }

        }
    }
    
    @ViewBuilder
    var appIcon : some View {
        if let url = appsManager.imageURLfor(appId: "\(suggestion.appId)") {
            CacheAsyncImage(url: url, scale: 2) { phase in
                switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .clipped()
                    case .failure(let error):
                        Text("E")
                            .onAppear {
                                print(error.localizedDescription)
                            }
                            .foregroundColor(.red)
                    case .empty:
                        Color.gray.opacity(0.05)
                    @unknown default:
                        // AsyncImagePhase is not marked as @frozen.
                        // We need to support new cases in the future.
                        Image(systemName: "questionmark")
                }
            }
            .frame(width: 18, height: 18)
        }
    }
}
