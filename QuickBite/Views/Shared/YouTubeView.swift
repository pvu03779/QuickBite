import SwiftUI
import WebKit

struct YouTubeView: UIViewRepresentable {
    let youTubeId: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/watch?v=\(youTubeId)") else { return }
        uiView.load(URLRequest(url: url))
    }
}
