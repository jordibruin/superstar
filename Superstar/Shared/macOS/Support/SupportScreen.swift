//
//  SupportScreen.swift
//  Vivid
//
//  Created by Jordi Bruin on 09/04/2022.
//

import SwiftUI

struct SupportScreen: View {
    
    @StateObject var fetcher = SupportFetcher()
    
    @State var selectedSection: FAQSection?
    
    var body: some View {
        NavigationView {
            Group {
                if fetcher.faqSections.isEmpty {
                    VStack(spacing: 0) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading Support")
                    }
                } else {
                    sidebar
                }
            }
            .frame(width: 260)
            
            
            // Automatically open FAQ when loaded?
            //            .onChange(of: fetcher.faqSections) { newValue in
            //                if !fetcher.faqSections.isEmpty {
            //                    if let firstSection = fetcher.faqSections.first {
            //                        selectedSection = firstSection
            //                    }
            //                }
            //            }
            
//            SupportSectionDetailView(section: FAQSection(id: 1, title: "faq", items: [
//                FAQItem(id: 1, title: "title", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
//                FAQItem(id: 2, title: "title", text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor .")
//            ]))
            
            SupportLanding()
                .navigationTitle("Support")
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    var sidebar: some View {
        VStack {
            List {
                ForEach(fetcher.faqSections) { section in
                    NavigationLink(
                        tag: section,
                        selection: $selectedSection
                    ) {
                        SupportSectionDetailView(section: section)
                    } label: {
                        HStack(spacing: 6) {
                            Text(section.title.prefix(1))
                            Text(String(section.title.dropFirst()))
                        }
                        .foregroundColor(.primary)
                        .font(.system(.title3, design: .rounded))
                        .padding(.vertical, 8)
                        .padding(.leading, 4)
                    }
                }
                
                Link(destination: URL(string: "mailto:jordi@goodsnooze.com")!) {
                    HStack(spacing: 6) {
                        Text("📨")
                        Text("Contact Support")
                    }
                    .foregroundColor(.primary)
                    .font(.system(.title3, design: .rounded))
                    .padding(.vertical, 8)
                    .padding(.leading, 4)
                }
            }
            .clipped()
            .toolbar(content: { ToolbarItem(content: {
                Text("Support")
                    .font(.title2)
                    .bold()
                })
            })
        }
    }
}

struct SupportScreen_Previews: PreviewProvider {
    static var previews: some View {
        SupportScreen()
    }
}

