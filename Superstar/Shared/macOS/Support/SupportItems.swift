//
//  SupportItem.swift
//  Supporter
//
//  Created by Jordi Bruin on 01/12/2021.
//

import Foundation

class SupportItems: Codable {
    var faqSections: [FAQSection]?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.faqSections = try container.decodeIfPresent([FAQSection].self, forKey: .faqSections)
    }
}

