import SwiftUI
import WebKit
import Pow


struct GifImageView2: UIViewRepresentable {
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
                        background-color: #DDD6C4;
                    }
                    img {
                        display: block;
                        width: 300;
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

struct LoadText: View{
    let text: String
    var body: some View {
        Text(text)
            .foregroundColor(Color(hexStringToUIColor(hex: "956F5C")))
            .font(Font.custom("CircularSpUIv3T-Bold", size: 25))
            .padding(.top, -7)
            .contentTransition(.numericText())
    }
}

struct LoaderFullScreen: View {
    let text: String
    @State private var isLoading = true
    var body: some View {
        ZStack(alignment: .top){
        Image("loading2")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            VStack{
                GifImageView2("fire")
                    .frame(width: 80, height: 90)
                    .cornerRadius(7)
                    .padding(.top, 123)
                    .padding(.leading, 10)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                
                if !isLoading {
                    LoadText(text: text)
                        .transition(
                        .movingParts.boing
                        .combined(with: .opacity)
                        .animation(
                          .interactiveSpring(dampingFraction: 0.35)
                        )
                        )
                    
                }
                    
            }
                
        }.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
       
}

#Preview {
    LoaderFullScreen(text: "Setting up")
}
