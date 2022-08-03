//
//  ReviewSortOrder.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 30/07/2022.
//

import Foundation
import AppStoreConnect_Swift_SDK

enum ReviewSortOrder: String, Identifiable, CaseIterable, Codable {
    case ratingAscending
    case ratingDescending
    case dateAscending
    case dateDescending
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .ratingAscending:
            return "Rating (High)"
        case .ratingDescending:
            return "Rating (Low)"
        case .dateAscending:
            return "Date (Old-New)"
        case .dateDescending:
            return "Date (New-Old)"
        }
    }
    
    var apiSort: AppStoreConnect_Swift_SDK.APIEndpoint.V1.Apps.WithID.CustomerReviews.GetParameters.Sort {
        switch self {
        case .ratingAscending:
            return .minusrating
        case .ratingDescending:
            return .rating
        case .dateAscending:
            return .createdDate
        case .dateDescending:
            return .minusrating
        }
    }
}
