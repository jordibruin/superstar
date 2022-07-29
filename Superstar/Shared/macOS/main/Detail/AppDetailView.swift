//
//  AppDetailView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
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

struct AppDetailView: View {
    
    @ObservedObject var appsManager: AppsManager
    @ObservedObject var reviewManager: ReviewManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    let app: AppStoreConnect_Swift_SDK.App
    
    @Binding var selectedReview: CustomerReview?
    
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    @State var hidePending: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if reviewManager.loadingReviews {
                loading
                    .frame(maxWidth: .infinity)
            } else {
                if reviewManager.retrievedReviews.isEmpty {
                    noReviews
                } else {
                    ScrollView {
                        AppReviewsList(
                            reviewManager: reviewManager,
                            hidePending: hidePending,
                            selectedReview: $selectedReview
                        )
                    }
                    .clipped()
                }
            }
        }
        .toolbar(content: { toolbarItems })
        
        
        // there is no title anymore so let's fake it.
        .onTapGesture {
            selectedReview = nil
        }
        .onAppear {
            Task {
                await reviewManager.getReviewsFor(
                    id: app.id,
                    sort: selectedSortOrder
                )
            }
        }
    }
    
    
//    @ToolbarContentBuilder
//    var toolbarContent: some View {
//        if selectedReview == nil {
//            toolbarItems
//        } else {
//            toolbarItems
//        }
//    }
    
    @AppStorage("selectedSortOrder") var selectedSortOrder: ReviewSortOrder = .dateDescending
    
    var toolbarItems: some ToolbarContent {
        Group {
//            ToolbarItem(placement: .navigation) {
//                HStack {
//                    if let url = appsManager.imageURL(for: app) {
//                        CacheAsyncImage(url: url, scale: 2) { phase in
//                            switch phase {
//                            case .success(let image):
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .clipShape(RoundedRectangle(cornerRadius: 9))
//                                    .clipped()
//                            case .failure(let _):
//                                Text("E")
//                            case .empty:
//                                Color.gray.opacity(0.05)
//                            @unknown default:
//                                // AsyncImagePhase is not marked as @frozen.
//                                // We need to support new cases in the future.
//                                Image(systemName: "questionmark")
//                            }
//                        }
//                        .frame(width: 32, height: 32)
//                    } else {
//                        RoundedRectangle(cornerRadius: 12)
//                            .foregroundColor(.blue)
//                            .frame(width: 32, height: 32)
//                    }
//
//                    VStack(alignment: .leading) {
//                        Text(app.attributes?.name ?? "")
//                            .font(.headline)
//
//                        Text(reviewManager.loadingReviews ? "" : "\(unansweredReviewCount) unanswered reviews")
//                            .font(.system(.subheadline, design: .rounded))
//                            .opacity(0.6)
//                    }
//
//                    Spacer()
//                }
//                .padding(.bottom, -4)
//            }
            
            ToolbarItem(placement: .primaryAction) {
                Spacer()
            }
            
            ToolbarItem(placement: .primaryAction) {
                
                Picker(selection: $selectedSortOrder) {
                    ForEach(ReviewSortOrder.allCases) { order in
                        Text(order.title)
                            .tag(order)
                    }
                } label: {
                    Text(selectedSortOrder.rawValue.capitalized)
                }
                .onChange(of: selectedSortOrder) { _ in
                    Task {
                        await reviewManager.getReviewsFor(id: app.id, sort: selectedSortOrder)
                    }
                }

                Toggle(isOn: $hidePending) {
                    Text("Hide Pending")
                }
                .help(Text("Hide reviews that you have responded to but are still pending publication"))
            }
            
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $hidePending) {
                    Text("Hide Pending")
                }
                .help(Text("Hide reviews that you have responded to but are still pending publication"))
            }
        }
    }
    
    var loading: some View {
        ZStack {

            VStack {
                Spacer()
                VStack {
                    ProgressView()
                        .scaleEffect(0.5)
                    
                    Text("Loading Reviews")
                        .font(.system(.title2, design: .rounded))
                    
                }
                Spacer()
            }
        }
    }
    
    var noReviews: some View {
        VStack {
            Spacer()
            VStack {
                Text("No reviews without a response found")
                    .font(.system(.title2, design: .rounded))
            }
            Spacer()
        }
        .frame(maxHeight: .infinity)
    }
     
    var unansweredReviewCount: Int {
        return reviewManager.retrievedReviews.filter { !pendingPublications.contains($0.id) }.count
    }
    
}

//struct AppDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppDetailView()
//    }
//}

