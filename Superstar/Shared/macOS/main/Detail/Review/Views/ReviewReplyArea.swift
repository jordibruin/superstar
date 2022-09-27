//
//  ReviewReplyArea.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI

struct ReviewReplyArea: View {
    
    var isReplyFocused: FocusState<Bool>.Binding
    @Binding var replyText : String
    @Binding var hoveringOnSuggestion : Suggestion?
    @ObservedObject var translator : DeepL
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(.controlBackgroundColor)
                .frame(height: 200)
                .onTapGesture {
                    isReplyFocused.wrappedValue = true
                }
            
            TextEditor(text: $replyText)
                .focused(isReplyFocused)
                .padding(8)
            //                .frame(height: replyText.count < 30 ? 44 : replyText.count < 110 ? 70 : 110)
                .frame(height: 200)
                .overlay(
                    TextEditor(text: .constant(hoveringOnSuggestion != nil ? hoveringOnSuggestion?.text ?? "" : "Custom Reply"))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .allowsHitTesting(false)
                        .opacity(replyText.isEmpty ? 1 : 0)
                        .frame(height: 200)
                )
                .overlay(
                    HStack {
                        Spacer()
                        Button {
                            translator.translateReply(text: replyText)
                        } label: {
                            Text("Translate")
                        }
                        
                    }
                )
        }
        .font(.system(.title3, design: .rounded))
        .cornerRadius(8)
    }
}
