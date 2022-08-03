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
                if let url = appsManager.imageURLfor(appId: "\(suggestion.appId)") {
                    CacheAsyncImage(url: url, scale: 2) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                .clipped()
                        case .failure(let _):
                            Text("E")
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
                
                //                        Text(appsManager.appNameFor(appId: "\(suggestion.appId)"))
                Text(suggestion.title.capitalized)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(hoveringOnSuggestion != nil && hoveringOnSuggestion! == suggestion ? Color.secondary.opacity(0.3) : Color(.controlBackgroundColor))
            .foregroundColor(.primary)
            .cornerRadius(6)
        }
        .onHover(perform: { hover in
            if hover {
                hoveringOnSuggestion = suggestion
            } else {
                hoveringOnSuggestion = nil
            }
        })
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
}

//struct SuggestionView_Previews: PreviewProvider {
//    static var previews: some View {
//        SuggestionView(suggestion: <#T##Suggestion#>, replyText: <#T##Binding<String>#>, hoveringOnSuggestion: <#T##Binding<Suggestion?>#>, suggestions: <#T##Binding<[Suggestion]>#>)
//    }
//}
