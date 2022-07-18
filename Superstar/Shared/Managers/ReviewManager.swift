//
//  ReviewManager.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 16/07/2022.
//

import Foundation
import Bagbutik


extension Bagbutik.CustomerReview: Equatable {
    public static func == (lhs: Bagbutik.CustomerReview, rhs: Bagbutik.CustomerReview) -> Bool {
        return lhs.id == rhs.id
    }
    
}

class ReviewManager: ObservableObject {
    
    @Published var retrievedReviews: [Bagbutik.CustomerReview] = []
    @Published var loadingReviews = false
    
    @MainActor
    func getReviewsFor(id: String) async {
        loadingReviews = true
        do {
            guard let jwt = CredentialsManager.shared.getJWT(), let service = try? BagbutikService(jwt: jwt) else { return }
                
            let response = try await service.request(
                .listCustomerReviewsForAppV1(
                    id: id,
                    exists: [.publishedResponse(false)],
                    sorts: [.createdDateAscending]
                )
            )

//            var reviewsWithoutResponse: [CustomerReview] = []
//
//            for review in response.data {
//                if let responseId = review.relationships?.response?.data?.id {
//                    let resp = try await service.request(
//                        .getResponseForCustomerReviewV1(id: review.id)
//                    )
//
//                    print("response?:")
//                    print(resp)
//                } else {
//                    reviewsWithoutResponse.append(review)
//                }
//            }
            
            self.retrievedReviews = response.data //.filter( { $0.relationships?.response?.data?.id == nil } )
            loadingReviews = false
        } catch {
            let nsEr = error as NSError
            print(nsEr)
            print(nsEr.domain)
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func replyTo(review: CustomerReview, with response: String) async -> Bool {
//        Task {
            do {
                guard let jwt = CredentialsManager.shared.getJWT(), let service = try? BagbutikService(jwt: jwt) else { return false }
                
                let requestBody = CustomerReviewResponseV1CreateRequest.init(
                    data: CustomerReviewResponseV1CreateRequest.Data.init(attributes: .init(responseBody: response), relationships: .init(review: .init(data: .init(id: review.id)))))
                
                let response = try await service.request(
                    .createCustomerReviewResponseV1(requestBody: requestBody)
                )
                
                if let state = response.data.attributes?.state {
                    if state == .pendingPublish {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.remove(review: review)
                        }
                    }
                }
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
//        }
    }
    
    func remove(review: CustomerReview) {
        if let index = retrievedReviews.firstIndex(where: { review.id == $0.id }) {
            retrievedReviews.remove(at: index)
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
