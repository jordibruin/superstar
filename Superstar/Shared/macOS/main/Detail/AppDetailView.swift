//
//  AppDetailView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
import Bagbutik

struct AppDetailView: View {
    
    @ObservedObject var appsManager: AppsManager
    @ObservedObject var reviewManager: ReviewManager
    let app: Bagbutik.App
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
            
            if let selectedReview = selectedReview {
                FullReviewSide(review: selectedReview)
            }
        }
        .onAppear {
            Task { await reviewManager.getReviewsFor(id: app.id) }
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
        VStack {
            Text("No reviews without a response found")
        }
    }
    
    var columns: [GridItem] = [
        GridItem(.adaptive(minimum: 270, maximum: 400), spacing: 20)
    ]
    
    var reviewsList: some View {
        ScrollView {
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
//        LazyVGrid(
//            columns: columns,
//            alignment: .center,
//            spacing: 12
//        ) {
//            ForEach(reviewManager.retrievedReviews, id: \.id) { review in
//                DetailReviewView(
//                    review: review,
//                    reviewManager: reviewManager,
//                    selectMultiple: $selectMultiple,
//                    autoReply: $autoReply
//                )
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    selectedReview = review
//                }
//            }
//        }
//        .padding(12)
//        .padding(.vertical, 40)
//        .onTapGesture {
//            selectedReview = nil
//        }
        
    }
    
    
    
    var header: some View {
        HStack {
            if let url = appsManager.imageURL(for: app) {
                AsyncImage(url: url, scale: 2) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .clipped()
                } placeholder: {
                    Color.clear
                }
                .frame(width: 72, height: 72)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(.blue)
                    .frame(width: 72, height: 72)
            }
            
            VStack(alignment: .leading) {
                Text(app.attributes?.name ?? "")
                    .font(.system(.title, design: .rounded))
                    .bold()
                if !reviewManager.loadingReviews {
                    
                    Text("\(unansweredReviewCount) unanswered reviews")
                        .font(.system(.title2, design: .rounded))
                }
            }
            
            Spacer()
        }
        .padding()
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

