//
//  Suggestion.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 22/07/2022.
//

import Foundation
import SwiftCSV
struct Suggestion: Identifiable, Codable {
    
    var title: String
    var text: String
    let appId: Int
    
    var id: String { "\(appId)\(title)" }
    
    init(title: String, text: String, appId: Int) {
        self.title = title
        self.text = text
        self.appId = appId
    }
    init(csv: Named.Row) {
        self.title = csv["Title"] ?? ""
        self.text = csv["Text"] ?? ""
        self.appId = Int(csv["AppId"] ?? "0") ?? 0
    }
    
}
