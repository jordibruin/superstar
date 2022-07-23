//
//  Suggestion.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 22/07/2022.
//

import Foundation

struct Suggestion: Identifiable, Codable {
    
    var title: String
    var text: String
    let appId: Int
    
    var id: String { "\(self.appId) \(self.title) \(self.text)"}
}
