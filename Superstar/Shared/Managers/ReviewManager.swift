//
//  ReviewManager.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 16/07/2022.
//

import Foundation
import SwiftUI
import AppStoreConnect_Swift_SDK
import os.log


extension AppStoreConnect_Swift_SDK.CustomerReview: Equatable {
    public static func == (lhs: AppStoreConnect_Swift_SDK.CustomerReview, rhs: AppStoreConnect_Swift_SDK.CustomerReview) -> Bool {
        return lhs.id == rhs.id
    }
    
}

class ReviewManager: ObservableObject {
    
    @Published var retrievedReviews: [AppStoreConnect_Swift_SDK.CustomerReview] = []
    @Published var loadingReviews = false
    
    @Published var replyText = ""
    
    @MainActor
    func getReviewsFor(id: String, sort: ReviewSortOrder) async {
        loadingReviews = true
        do {
            let provider = APIProvider(configuration: CredentialsManager.shared.configuration)
            let request = APIEndpoint
                .v1
                .apps
                .id(id)
                .customerReviews
                
                .get(parameters: .init(isExistsPublishedResponse: false, sort: [sort.apiSort]))
            
            let reviews = try await provider.request(request)
                
            let reviewsData = reviews.data
            
//            let pages = reviews.meta?.paging.total
//            print(pages)
//            reviews
//            var reviewsWithoutResponse: [CustomerReview] = []
            
            self.retrievedReviews = reviewsData
            loadingReviews = false
        } catch {
            let nsEr = error as NSError
            print(nsEr)
            print(nsEr.domain)
            print(error.localizedDescription)
        }
    }

    func getSales() async {
        do {
            let provider = APIProvider(configuration: CredentialsManager.shared.configuration)
            let request = APIEndpoint
                .v1
                .salesReports
                .get(parameters: .init(filterFrequency: [.daily], filterReportSubType: [.summary], filterReportType: [.sales], filterVendorNumber: ["89141975"]))
            
            let sales = try await provider.request(request)
                
            print(sales)
            
            
//            let reviewsData = reviews.data
            
//            let pages = reviews.meta?.paging.total
//            print(pages)
//            reviews
//            var reviewsWithoutResponse: [CustomerReview] = []
            
//            self.retrievedReviews = reviewsData
//            loadingReviews = false
        } catch {
            let nsEr = error as NSError
            print(nsEr)
            print(nsEr.domain)
            print(error.localizedDescription)
        }
    }
    
    @State var showError = false
    @State var errorString = ""
    
    @MainActor
    func replyTo(review: CustomerReview, with response: String) async throws -> Bool {
            do {
                let provider = APIProvider(configuration: CredentialsManager.shared.configuration)
                
                let replyBody = response
                let reviewResponse = CustomerReviewResponseV1CreateRequest.Data.Relationships.Review(
                    data: .init(
                        type: .customerReviews,
                        id: review.id
                    )
                )
                
                let replyRequest = APIEndpoint.v1.customerReviewResponses
                    .post(CustomerReviewResponseV1CreateRequest(
                        data:.init(
                            type: .customerReviewResponses,
                            attributes: .init(responseBody: replyBody),
                            relationships: .init(review: reviewResponse)
                        )
                    )
                    )
                
                    let responseState = try await provider.request(replyRequest)
                
                    if let state = responseState.data.attributes?.state {
                        if state == .pendingPublish {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.remove(review: review)
                            }
                        }
                    }
                
                    return true
                
            } catch {
                // HOE KAN IK HIER DE ERROR DOORGEVEN? ☢️
//                print(error.localizedDescription)
                print(error)
//                print(error
                let headerInfoKeys = (error as NSError).attributeKeys
                
                print(headerInfoKeys)
                print((error as NSError).description)
                
                let errorCode = (error as NSError).description
                if errorCode.contains("This request is forbidden for security reasons") {
                    print("Not enough rights")
                }
                    
                showError = true
                errorString = error.localizedDescription
                
                let nsError = error as NSError
                print(nsError.code)
                print(nsError.domain)
                throw error
                return false
            }
    }
    
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    func remove(review: CustomerReview) {
        if let index = retrievedReviews.firstIndex(where: { review.id == $0.id }) {
            pendingPublications.append(review.id)
//            retrievedReviews.remove(at: index)
        }
    }
    
    func getScoresForReviews() -> (Int, Int, Int, Int, Int) {
        
        var one = 0
        var two = 0
        var three = 0
        
        for review in retrievedReviews {
            if let rating = review.attributes?.rating {
                switch rating {
                case 1:
                    one += 1
                case 2:
                    two += 1
                case 3:
                    three += 1
                default:
                    continue
                }
            }
        }
        
        return (one, two, three, one, one)
    }
}
