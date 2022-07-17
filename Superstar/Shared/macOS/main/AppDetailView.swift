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
    
    var body: some View {
        VStack {
            header

            ScrollView {
                if reviewManager.loadingReviews {
                    loading
                } else {
                    if reviewManager.retrievedReviews.isEmpty {
                        noReviews
                    } else {
                        reviewsList
                    }
                }
            }
        }
        
        .onAppear {
            Task {
                await reviewManager.getReviewsFor(id: app.id)
            }
        }
    }
    
    var loading: some View {
        VStack {
            ProgressView()
            Text("Loading Reviews")
        }
    }

    var noReviews: some View {
        VStack {
            Text("No reviews without a response found")
        }
    }
    
    var reviewsList: some View {
        VStack(spacing: 32) {
            ForEach(reviewManager.retrievedReviews, id: \.id) { review in
                DetailReviewView(review: review, reviewManager: reviewManager)
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }
    
    var header: some View {
        HStack {
            AsyncImage(url: appsManager.imageURL(for: app), scale: 2) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .clipped()
            } placeholder: {
                Color.clear
            }
            .frame(width: 72, height: 72)
            
            VStack(alignment: .leading) {
                Text(app.attributes?.name ?? "")
                        .font(.title)
                if !reviewManager.loadingReviews {
                    Text("\(reviewManager.retrievedReviews.count) ratings")
                }
            }
            
            Spacer()
        }
        .padding(12)
    }
    
}

//struct AppDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppDetailView()
//    }
//}

