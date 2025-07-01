import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    let onURLChange: (URL) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        private let scheme = Bundle.main.object(forInfoDictionaryKey: "SCHEME") as! String
        private let redirectHost = Bundle.main.object(forInfoDictionaryKey: "NOTION_REDIRECT_HOST") as! String
        private let redirectPath = Bundle.main.object(forInfoDictionaryKey: "NOTION_REDIRECT_PATH") as! String
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        private func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            
            if let url = navigationAction.request.url {
                // ディープリンクのスキームをチェック
                if url.scheme == scheme {
                    Task { @MainActor in
                        self.parent.onURLChange(url)
                    }
                    decisionHandler(.cancel)
                    return
                }
                
                // 通常のURL変更もコールバック
                Task { @MainActor in
                    self.parent.onURLChange(url)
                }
            }
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url {
                // Redirect URL のチェック
                if url.host == redirectHost,
                   url.path.contains(redirectPath),
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems,
                   let _ = queryItems.first(where: { $0.name == "code" })?.value {
                    
                    // DeepLink を生成
                    var deepLinkComponents = URLComponents()
                    deepLinkComponents.scheme = scheme
                    deepLinkComponents.host = "oauth"
                    deepLinkComponents.queryItems = queryItems
                    
                    if let deepLinkURL = deepLinkComponents.url {
                        Task { @MainActor in
                            self.parent.onURLChange(deepLinkURL)
                        }
                        return
                    }
                }
                
                Task { @MainActor in
                    self.parent.onURLChange(url)
                }
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView provisional navigation failed: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            if let url = webView.url {
                print("🔄 WebView received server redirect to: \(url.absoluteString)")
                Task { @MainActor in
                    self.parent.onURLChange(url)
                }
            }
        }
    }
} 
