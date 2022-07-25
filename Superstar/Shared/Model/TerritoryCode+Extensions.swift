//
//  TerritoryCode+Extensions.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 22/07/2022.
//

import Foundation
import AppStoreConnect_Swift_SDK

extension TerritoryCode {
    
    var flag: String {
        switch self {
        case .usa:
            return "🇺🇸"
        case .nld:
            return "🇳🇱"
        case .ukr:
            return "🇺🇦"
        case .arg:
            return "🇦🇷"
        case .aus:
            return "🇦🇺"
        case .chn:
            return "🇨🇳"
        default:
            return "🌎"
        }
    }
}
