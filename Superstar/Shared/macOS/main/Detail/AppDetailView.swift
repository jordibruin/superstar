//
//  AppDetailView.swift
//  🌟 Superstar
//
//  Created by Jordi Bruin on 17/07/2022.
//

import SwiftUI
import AppStoreConnect_Swift_SDK

struct AppDetailView: View {
    
    @EnvironmentObject var appsManager: AppsManager
    @EnvironmentObject var reviewManager: ReviewManager
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
                    
//                    ScrollView {
                    ZStack {
                        Color(.controlBackgroundColor)
                        AppReviewsList(
                            reviewManager: reviewManager,
                            hidePending: hidePending,
                            selectedReview: $selectedReview,
                            searchText: searchText
                        )
                    }
//                    }
                    
//                    .frame(width: 300)
//                    .frame(maxWidth: 350)
//                    .clipped()
                }
            }
        }
        
        .toolbar(content: { toolbarItems })
        .searchable(text: $searchText)
        
        // there is no title anymore so let's fake it.
        .onTapGesture {
            selectedReview = nil
        }
        .onAppear {
            Task {
//                await reviewManager.getSales()
                
                await reviewManager.getReviewsFor(
                    id: app.id,
                    sort: selectedSortOrder
                )
            }
        }
    }
    
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
          
            
//            ToolbarItem(placement: .primaryAction) {
//                TextField("Search", text: $searchText)
//                    .textFieldStyle(.squareBorder)
//                    .frame(width: 120)
//            }
            
            
            ToolbarItemGroup(placement: .confirmationAction) {
                
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
                            //                        await reviewManager.getSales()
                            await reviewManager.getReviewsFor(id: app.id, sort: selectedSortOrder)
                        }
                    }
                
                
                    //                Toggle(isOn: $hidePending) {
                    //                    Text("Hide Pending")
                    //                }
                    //                .help(Text("Hide reviews that you have responded to but are still pending publication"))
                
                
                    Toggle(isOn: $hidePending) {
                        Image(systemName: hidePending ? "eye.slash" : "eye")
                    }
                    .help(Text("Hide reviews that you have responded to but are still pending publication"))
                
            }
            
        }
    }
    
    @State var searchText = ""
    
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

