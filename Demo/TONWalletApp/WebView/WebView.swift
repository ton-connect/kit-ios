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
    let url: URL
    let walletKit: TONWalletKit
    
    func makeCoordinator() -> Coordinator {
        Coordinator(walletKit: walletKit)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // Register message handler for bridge requests
        userContentController.add(context.coordinator, name: "tonconnect")
        
        // Load and inject the bridge script from TONWalletKit bundle
        do {
            let scriptContent = try TONWalletKit.loadInjectScript()
            let userScript = WKUserScript(
                source: scriptContent,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            userContentController.addUserScript(userScript)
            debugPrint("✅ Successfully loaded inject.mjs script (\(scriptContent.count) bytes)")
        } catch {
            debugPrint("⚠️ Failed to load inject.mjs script:", error)
            debugPrint("📁 Available bundles:")
            debugPrint("  - Bundle.main.resourcePath:", Bundle.main.resourcePath ?? "nil")
            debugPrint("  - Bundle.main.bundlePath:", Bundle.main.bundlePath)
        }
        
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isInspectable = true
        context.coordinator.webView = webView
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler {
        weak var webView: WKWebView?
        private let bridgeManager: WebViewBridgeManager
        
        init(walletKit: TONWalletKit) {
            self.bridgeManager = WebViewBridgeManager(walletKit: walletKit)
            super.init()
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "tonconnect" else { return }
            
            debugPrint("📨 Received message from WebView:", message.body)
            
            Task { @MainActor in
                // Process the message through bridge manager
                let responseJSON = await bridgeManager.processMessage(message.body)
                
                // Send response back to WebView
                let script = """
                window.postMessage(\(responseJSON), '*');
                """
                
                webView?.evaluateJavaScript(script) { result, error in
                    if let error = error {
                        debugPrint("❌ Error sending response to WebView:", error)
                    } else {
                        debugPrint("✅ Response sent to WebView")
                    }
                }
            }
        }
    }
}
