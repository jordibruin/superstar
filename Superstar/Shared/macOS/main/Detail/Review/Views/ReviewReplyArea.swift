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
    
    var placeholderText : String {
        if let hoveringOnSuggestion {
            return hoveringOnSuggestion.text
        }
        return "Write response..."
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // Background
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                .frame(minHeight: 200)
                .onTapGesture {
                    isReplyFocused.wrappedValue = true
                }
            
            VStack(alignment: .leading) {
                
                TextEditor(text: $replyText)
                    .focused(isReplyFocused)
                    .padding(12)
                //                .frame(height: replyText.count < 30 ? 44 : replyText.count < 110 ? 70 : 110)
                    .frame(minHeight: 200)
                    .overlay(
                        VStack {
                            // Fale TextEditor
                            Text(placeholderText)
                                .foregroundColor(.secondary)
                                .allowsHitTesting(false)
                                .opacity(replyText.isEmpty ? 1 : 0)
                                .place(.leading)
                                .padding(.top, 13)
                                .padding(.leading, 17)
                            Spacer()
                        }
                    )
                replyOptions
                
                if !translator.translatedReply.isEmpty {
                    VStack(alignment: .leading) {
                        Text(translator.translatedReply)
                            .textSelection(.enabled)
                            .padding([.top, .horizontal])
                        HStack {
                            SmallButton(action: replaceText, title: "Replace Original", icon: "arrow.up.square")
                            SmallButton(action: addText, title: "Add to Original", icon: "text.line.first.and.arrowtriangle.forward")
                            SmallButton(action: copyText, title: "Copy Text", icon:"doc.on.clipboard")
                            Spacer()
                            
                        }
                    }
                    .padding([.horizontal, .bottom], 8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    .padding([.horizontal, .bottom], 8)
                }
            }
           
        }
        .font(.system(.title3, design: .rounded))
    }
    
    var replyOptions : some View {
        HStack {
            if replyText.isEmpty == false {
                SmallButton(action: {translator.translateReply(text: replyText)}, title: "Translate Your Reply")
            }
            Spacer()
            
            
            
            if replyText.isEmpty == false {
                SmallButton(action: {
                    replyText = ""
                    translator.translatedReply = ""
                }, title: "Clear")
            }
            
            Text("\(5970 - replyText.count)")
                .font(.system(.headline, design: .rounded).weight(.medium))
                .opacity(0.4)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
        }
        .padding(8)
    }
    
    private func replaceText() {
        replyText = translator.translatedReply
    }
    
    private func addText() {
        replyText = "\(translator.translatedReply)\n\n\(replyText)"
    }
    
    private func copyText() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(translator.translatedReply, forType: .string)
    }
}
