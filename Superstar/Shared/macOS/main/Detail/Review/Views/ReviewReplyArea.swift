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
    @State private var didReplaceText = false
    
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
                .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
                .frame(minHeight: 170)
                .onTapGesture {
                    isReplyFocused.wrappedValue = true
                }
            
            VStack(alignment: .leading) {
                
                TextEditor(text: $replyText)
                    .focused(isReplyFocused)
                    .padding(12)
                //                .frame(height: replyText.count < 30 ? 44 : replyText.count < 110 ? 70 : 110)
                    .frame(minHeight: 160)
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
                            if !didReplaceText {
                                SmallButton(action: replaceText, title: "Replace Original", icon: "arrow.up.square", helpText: "Replace your original reply with the translated version")
                                SmallButton(action: addText, title: "Add to Original", icon: "text.insert", helpText: "Add the translation to the original reply so you can send both.")
                            }
                            SmallButton(action: copyText, title: "Copy Text", icon:"doc.on.clipboard", helpText: "Copy the translation to your clipboard")
                            Spacer()
                            SmallButton(action: hideTranslationOptions, title: "Hide", icon:"", helpText: "Hide translated reply and options")
                            
                        }
                    }
                    .padding([.horizontal, .bottom], 8)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .padding([.horizontal, .bottom], 8)
                }
            }
           
        }
        .font(.system(.title3, design: .rounded))
    }
    
    var replyOptions : some View {
        HStack {
            if replyText.isEmpty == false {
                SmallButton(action: translateText, title: "Translate Your Reply", helpText: "Translate your reply using your setup DeepL API key.")
            }
            Spacer()
            
            if replyText.isEmpty == false {
                SmallButton(action: clearText, title: "Clear", helpText: "Clear the textfield for your reply")
            }
            
            Text("\(replyCharacterLimit - replyText.count)")
                .font(.system(.headline, design: .rounded).weight(.medium))
                .opacity(replyCharacterLimit - replyText.count < 0 ? 0.8 : 0.4)
                .foregroundColor(replyCharacterLimit - replyText.count < 0 ? .red : .primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
        }
        .padding([.horizontal, .top],8)
        .padding(.bottom, translator.translatedReply.isEmpty ? 8 : 4)
    }
    
    let replyCharacterLimit = 5970
    
    private func replaceText() {
        replyText = translator.translatedReply
        withAnimation {
            didReplaceText = true
            translator.translatedReply = ""
        }
    }
    
    private func addText() {
        replyText = "\(translator.translatedReply)\n\n\(replyText)"
    }
    
    private func copyText() {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(translator.translatedReply, forType: .string)
    }
    
    private func hideTranslationOptions() {
        withAnimation {
            translator.translatedReply = ""
        }
    }
    
    private func translateText() {
        withAnimation {
            translator.translateReply(text: replyText)
        }
    }
    
    private func clearText() {
        withAnimation {
            replyText = ""
            translator.translatedReply = ""
            didReplaceText = false
        }
    }
}
