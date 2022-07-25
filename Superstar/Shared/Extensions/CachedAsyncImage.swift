//
//  CachedAsyncImage.swift
//  Superstar (macOS)
//
//  Created by Jordi Bruin on 23/07/2022.
//

import Foundation

import SwiftUI

struct CacheAsyncImage<Content>: View where Content: View {

    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content

    init(
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    var body: some View {

        if let cached = ImageCache[url] {
//            let _ = print("cached \(url.absoluteString)")
            content(.success(cached))
        } else {
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ) { phase in
                cacheAndRender(phase: phase)
            }
        }
    }

    func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success(let image) = phase {
            ImageCache[url] = image
        }

        return content(phase)
    }
}

//struct CacheAsyncImage_Previews: PreviewProvider {
//    static var previews: some View {
//        CacheAsyncImage(
//            url: Pokemon.sample.url
//        ) { phase in
//            switch phase {
//            case .empty:
//                ProgressView()
//            case .success(let image):
//                image
//            case .failure(let error):
//                ErrorView(error: error)
//            @unknown default:
//                fatalError()
//            }
//        }
//    }
//}


fileprivate class ImageCache {
    static private var cache: [URL: Image] = [:]

    static subscript(url: URL) -> Image? {
        get {
            ImageCache.cache[url]
        }
        set {
            ImageCache.cache[url] = newValue
        }
    }
}
