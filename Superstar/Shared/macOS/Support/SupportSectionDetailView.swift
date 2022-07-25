//
//  SupportSectionDetailView.swift
//  Vivid
//
//  Created by Jordi Bruin on 11/04/2022.
//

import SwiftUI

struct SupportSectionDetailView: View {
    let section: FAQSection
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(section.items) { item in
                    FAQCell(item: item)
                }
            }
            .multilineTextAlignment(.leading)
            .padding(16)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SupportSectionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SupportSectionDetailView(section: FAQSection(id: 1, title: "", items: []))
    }
}

struct FAQCell: View {
    
    let item: FAQItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(.system(.title2, design: .rounded))
                    .bold()
                Spacer()
            }
            
            Text(item.text.toMarkdown())
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}


/// For rendering markdown in JSON input
extension String {
    
    func toMarkdown() -> AttributedString {
        do {
            return try AttributedString(markdown: self, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        } catch {
            print("Error parsing Markdown for string \(self): \(error)")
            return AttributedString(self)
        }
    }
}
