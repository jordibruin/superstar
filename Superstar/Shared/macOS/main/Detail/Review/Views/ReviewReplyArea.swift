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
        VStack(alignment: .leading) {
            
                TextEditor(text: $replyText)
                    .focused(isReplyFocused)
                    .padding(12)
                //                .frame(height: replyText.count < 30 ? 44 : replyText.count < 110 ? 70 : 110)
                    .frame(height: 200)
                    .overlay(
                        ZStack {
                            TextEditor(text: .constant(hoveringOnSuggestion != nil ? hoveringOnSuggestion?.text ?? "" : "Write response..."))
                                .foregroundColor(.secondary)
                                .padding(12)
                                .allowsHitTesting(false)
                                .opacity(replyText.isEmpty ? 1 : 0)
                                .frame(height: 200)
                            VStack {
                                Spacer()
                                HStack {
                                    
                                    if replyText.isEmpty == false {
                                        SmallButton(action: {translator.translateReply(text: replyText)}, title: "Translate Your Reply")
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(5970 - replyText.count)")
                                        .font(.system(.headline, design: .rounded).weight(.medium))
                                        .opacity(0.4)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                }
                                .padding(8)
                            }
                        }
                    )
                
                if !translator.translatedReply.isEmpty {
                    Text(translator.translatedReply)
                        .textSelection(.enabled)
                }
            }
        .font(.system(.title3, design: .rounded))
        .frame(height: 200)
        .onTapGesture {
            isReplyFocused.wrappedValue = true
        }
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}
