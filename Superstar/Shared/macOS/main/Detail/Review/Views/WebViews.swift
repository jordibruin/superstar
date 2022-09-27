//
//  WebViews.swift
//  Superstar (macOS)
//
//  Created by Hidde van der Ploeg on 27/09/2022.
//

import SwiftUI
import WebKit

struct WebView: View {
    
    let urlString: String
    
    var body: some View {
        WebViewWrapper(urlString: urlString)
    }
}

struct WebViewWrapper: NSViewRepresentable {
    
    let urlString: String
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        //        var newURL = urlString
        
        if let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: encoded) {
                let request = URLRequest(url: url)
                nsView.load(request)
            }
        }
    }
}
