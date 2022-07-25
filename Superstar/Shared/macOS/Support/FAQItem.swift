//
//  FAQItem.swift
//  Supporter
//
//  Created by Jordi Bruin on 05/12/2021.
//

import Foundation

struct FAQSection: Identifiable, Codable, SupportItemable, Equatable, Hashable {
    static func == (lhs: FAQSection, rhs: FAQSection) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let title: String
    let items: [FAQItem]
    var hasDetailPage: Bool
    var viewAllText: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.items = try container.decodeIfPresent([FAQItem].self, forKey: .items) ?? []
        self.hasDetailPage = try container.decodeIfPresent(Bool.self, forKey: .hasDetailPage) ?? false
        self.viewAllText = try container.decodeIfPresent(String.self, forKey: .viewAllText) ?? "View all"
    }
    
    init(id: Int, title: String, items: [FAQItem], hasDetailPage: Bool? = nil) {
        self.id = id
        self.title = title
        self.items = items
        self.hasDetailPage = hasDetailPage ?? false
        self.viewAllText = "View all"
    }

    static let example = FAQSection(id: 0, title: "Section title", items: [
        FAQItem(id: Int.random(in: 1...4032304), title: "How to enable subsitles", text: "Four simple steps"),
        FAQItem(id: Int.random(in: 1...4032304), title: "How to enable subsitles", text: "Four simple steps")
    ])
}

struct FAQItem: Identifiable, Codable, SupportItemable, Hashable {
    
    let id: Int
    let title: String
    let text: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
    }
    
    init(
        id: Int,
        title: String,
        text: String
    ) {
        self.id = id
        self.title = title
        self.text = text
    }
    
    static let example = FAQItem(id: Int.random(in: 1...4032304), title: "How to enable subsitles", text: "Four simple steps")
}
