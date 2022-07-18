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
               DetailReviewView(
                review: review,
                reviewManager: reviewManager,
                selectMultiple: $selectMultiple
               )
           }
       }
       .padding(12)
       .padding(.vertical, 40)
        
        
//        VStack(spacing: 32) {
//            ForEach(reviewManager.retrievedReviews, id: \.id) { review in
//                DetailReviewView(review: review, reviewManager: reviewManager)
//            }
//            .padding(.horizontal, 40)
//        }
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
                    .font(.system(.title, design: .rounded))
                    .bold()
                if !reviewManager.loadingReviews {
                    Text("\(reviewManager.retrievedReviews.count) unanswered reviews")
                        .font(.system(.title2, design: .rounded))
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
}

//struct AppDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppDetailView()
//    }
//}

