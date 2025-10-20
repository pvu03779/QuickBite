import SwiftUI
import WebKit

// A view that wraps a WKWebView to play YouTube videos.
struct YouTubeView: UIViewRepresentable {
    let youTubeId: String
    
    func makeUIView(context: Context) -> WKWebView {
        // Configure web view to not allow scrolling
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Construct the embed URL and load it
        guard let url = URL(string: "https://www.youtube.com/embed/\(youTubeId)") else { return }
        uiView.load(URLRequest(url: url))
    }
}
