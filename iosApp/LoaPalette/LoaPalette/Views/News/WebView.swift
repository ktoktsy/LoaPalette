
import SwiftUI
import WebKit

/// WKWebViewをSwiftUIで使用するためのUIViewRepresentable.
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let currentURL = webView.url?.absoluteString ?? ""
        let newURL = url.absoluteString
        if currentURL != newURL {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
    }
}
