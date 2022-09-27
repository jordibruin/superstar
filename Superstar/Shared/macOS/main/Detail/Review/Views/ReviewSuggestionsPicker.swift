//
//  ReviewSuggestionsPicker.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI

struct ReviewSuggestionsPicker: View {
    @EnvironmentObject var appsManager: AppsManager

    @Binding var replyText : String
    @AppStorage("onlyShowSuggestionsPerApp") var onlyShowSuggestionsPerApp: Bool = true
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    @Binding var hoveringOnSuggestion: Suggestion?
    
    var showedSuggestions : [Suggestion] {
        if onlyShowSuggestionsPerApp {
            return suggestions.filter({ $0.appId == Int(appsManager.selectedAppId ?? "") ?? 0 || $0.appId == 0 })
        }
        
        return suggestions
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Response Suggestions")
                    .font(.system(.body, design: .rounded))
                    .bold()
                
                Spacer()
                
                Button {
                    if appsManager.selectedAppId != "Placeholder" {
                        let suggestion = Suggestion(
                            title: replyText.components(separatedBy: ".").first ?? "New Suggestion",
                            text: replyText,
                            appId: Int(appsManager.selectedAppId ?? "0") ?? 0
                        )
                        suggestions.append(suggestion)
                    }
                } label: {
                    Text("Add Suggestion")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 6)
                        .background(Color(.controlBackgroundColor))
                        .foregroundColor(.primary)
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .opacity(replyText.isEmpty ? 0 : 1)
            }
            
            ForEach(Array(zip(showedSuggestions.indices, showedSuggestions)), id: \.0) { index, suggestion in
                SuggestionView(
                    suggestion: showedSuggestions[index],
                    replyText: $replyText,
                    hoveringOnSuggestion: $hoveringOnSuggestion,
                    suggestions: $suggestions)
                .keyboardShortcut(KeyEquivalent(Character(UnicodeScalar(index)!)), modifiers: .shift)
            }
            
        }
    }
}
