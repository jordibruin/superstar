//
//  AppDetailView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppDetailView: View {
    
    @ObservedObject var appsManager: AppsManager
    @ObservedObject var reviewManager: ReviewManager
    let app: AppStoreConnect_Swift_SDK.App
    @Binding var autoReply: Bool
    
    @Binding var selectedReview: CustomerReview?
    
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    @AppStorage("suggestions") var suggestions: [Suggestion] = []
    
    @State var hidePending: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if reviewManager.loadingReviews {
                loading
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    if reviewManager.retrievedReviews.isEmpty {
                        noReviews
                    } else {
                        reviewsList
                            .animation(.default, value: reviewManager.retrievedReviews)
                            .id(UUID())
                    }
                }
                .clipped()
            }
        }
        .toolbar(content: { toolbarItems })
        
        // there is no title anymore so let's fake it.
        .onTapGesture {
            selectedReview = nil
        }
        .onAppear {
            Task { await reviewManager.getReviewsFor(id: app.id) }
        }
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigation) {
                HStack {
                    if let url = appsManager.imageURL(for: app) {
                        CacheAsyncImage(url: url, scale: 2) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 9))
                                    .clipped()
                            case .failure(let _):
                                Text("E")
                            case .empty:
                                Color.gray.opacity(0.05)
                            @unknown default:
                                // AsyncImagePhase is not marked as @frozen.
                                // We need to support new cases in the future.
                                Image(systemName: "questionmark")
                            }
                        }
                        .frame(width: 32, height: 32)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(app.attributes?.name ?? "")
                            .font(.headline)
                        
                        Text(reviewManager.loadingReviews ? "" : "\(unansweredReviewCount) unanswered reviews")
                            .font(.system(.subheadline, design: .rounded))
                            .opacity(0.6)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, -4)
            }
            
            ToolbarItem(placement: .primaryAction) {
                Spacer()
            }
            
            ToolbarItem(placement: .primaryAction) {
                Toggle(isOn: $hidePending) {
                    Text("Hide Pending")
                }
            }
        }
    }
    
    var loading: some View {
        ZStack {
            Color(.controlBackgroundColor)
            VStack {
                Spacer()
                VStack {
                    ProgressView()
                    Text("Loading Reviews")
                }
                Spacer()
            }
        }
    }
    
    var noReviews: some View {
        ZStack {
            Color(.controlBackgroundColor)
            VStack {
                Spacer()
                VStack {
                    Text("No reviews without a response found")
                }
                Spacer()
            }
        }
    }
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: 480), spacing: 20)
    ]
    
    var reviewsList: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 12
        ) {
            ForEach(reviewManager.retrievedReviews, id: \.id) { review in
                if hidePending {
                    if !pendingPublications.contains(review.id) {
                        Button {
                            selectedReview = review
                        } label: {
                            DetailReviewView(
                                review: review,
                                reviewManager: reviewManager,
                                autoReply: $autoReply,
                                selectedReview: $selectedReview
                            )
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    Button {
                        selectedReview = review
                    } label: {
                        DetailReviewView(
                            review: review,
                            reviewManager: reviewManager,
                            autoReply: $autoReply,
                            selectedReview: $selectedReview
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .padding(.vertical)
    }
    
    var header: some View {
        HStack {
            if let url = appsManager.imageURL(for: app) {
                CacheAsyncImage(url: url, scale: 2) { phase in
                    switch phase {
                    case .success(let image):
                        
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                            .clipped()
                    case .failure(let _):
                        Text("E")
                    case .empty:
                        Color.gray.opacity(0.05)
                    @unknown default:
                        // AsyncImagePhase is not marked as @frozen.
                        // We need to support new cases in the future.
                        Image(systemName: "questionmark")
                    }
                }
                .frame(width: 40, height: 40)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading) {
                Text(app.attributes?.name ?? "")
                    .font(.system(.body, design: .rounded))
                    .bold()
                if !reviewManager.loadingReviews {
                    Text("\(unansweredReviewCount) unanswered reviews")
                        .font(.system(.caption, design: .rounded))
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color(.controlBackgroundColor))
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

