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
    @Binding var selectMultiple: Bool
    @Binding var autoReply: Bool
    
    @State var selectedReview: CustomerReview?
    
    @AppStorage("pendingPublications") var pendingPublications: [String] = []
    
    var body: some View {
//        HStack(spacing: 0) {
        HSplitView {
            VStack(spacing: 0) {
                header
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
                        }
                    }
                    .background(Color(.controlBackgroundColor))
                }
            }
            .background(Color(.controlBackgroundColor))
            .onTapGesture {
                selectedReview = nil
            }
            
            FullReviewSide(review: selectedReview)
        }
        .toolbar(content: { toolbarItems })
        .onAppear {
            Task { await reviewManager.getReviewsFor(id: app.id) }
        }
    }
    
    var toolbarItems: some ToolbarContent {
            Group {
                ToolbarItem(placement: .primaryAction) {
                    Toggle(isOn: $autoReply) {
                        Text("Auto Reply")
                            .help(Text("Automatically send response when you select a template reply."))
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
        GridItem(.adaptive(minimum: 270, maximum: 400), spacing: 20)
    ]
    
    var reviewsList: some View {
        LazyVGrid(
            columns: columns,
            alignment: .center,
            spacing: 12
        ) {
            ForEach(reviewManager.retrievedReviews, id: \.id) { review in
                Button {
                    selectedReview = review
                } label: {
                    DetailReviewView(
                        review: review,
                        reviewManager: reviewManager,
                        selectMultiple: $selectMultiple,
                        autoReply: $autoReply
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .padding(.vertical, 40)
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

