//
//  WebView.swift
//  TONWalletApp
//
//  Created by Nikita Rodionov on 21.10.2025.
//

import SwiftUI
import WebKit
import TONWalletKit

struct WebView: UIViewRepresentable {
    let walletKit: TONWalletKit
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        try? webView.inject(walletKit: walletKit)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}
