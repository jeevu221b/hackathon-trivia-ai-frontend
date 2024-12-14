import SwiftUI
import WebKit

struct GifImageView: UIViewRepresentable {
    private let name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        
        if let asset = NSDataAsset(name: name) {
            let data = asset.data
            let base64String = data.base64EncodedString(options: .lineLength64Characters)
            
            let html = """
            <html>
            <head>
                <style>
                    body {
                        margin: 0;
                        padding: 0;
                        background-color: transparent;
                    }
                    img {
                        display: block;
                        width: 100%;
                        height: auto;
                    }
                </style>
            </head>
            <body>
                <img src="data:image/gif;base64,\(base64String)" alt="GIF" />
            </body>
            </html>
            """
            
            webview.loadHTMLString(html, baseURL: nil)
        }
        
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No need to update the view, as the GIF will loop automatically
    }
}
