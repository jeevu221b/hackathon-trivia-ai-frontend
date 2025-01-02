import SwiftUI
import WebKit

struct GifImageView3: UIViewRepresentable {
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
                        background-color: #202020;
                    }
                    img {
                        display: block;
                        width: 500;
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

struct ReadyView: View {
    let levelId: String
    @State private var subcategoryName: String = ""
    @State private var categoryName: String = ""
    @State private var level: Int = 0
    @State private var subcategory: Subcategory?
    
    struct Player {
        let id: String
        let name: String
        let isReady: Bool
    }

    let players = [
        Player(id: "jeevu221b", name: "jeevu221b", isReady: true),
        Player(id: "santo", name: "santo", isReady: false),
        Player(id: "aliza", name: "aliza", isReady: true),
        Player(id: "aribaaa", name: "aribaaa", isReady: true),
        Player(id: "nitinnnn", name: "nitinnnn", isReady: true)
    ]
    
    private func fetchSubcategory(subcategoryId: String) {
        let subcategories = DataManager.shared.getSubcategories()
        let allLevels = DataManager.shared.getLevels()
        
        if let subcategory = subcategories.first(where: { $0.id == subcategoryId }) {
            self.subcategory = subcategory
        }
    }

    var body: some View {
        VStack {
//            VStack {
//                LazyVGrid(columns: [
//                    GridItem(.fixed(115), alignment: .top),
//                    GridItem(.fixed(115), alignment: .top),
//                    GridItem(.fixed(115), alignment: .top),
//                ]) {
//                    ForEach(players, id: \.id) { player in
//                        VStack(alignment: .center, spacing: 5) {
//                            HStack {
//                                VStack(alignment: .leading, spacing: 0) {
//                                    Text(player.name)
//                                        .font(Font.custom("CircularSpUIv3T-Book", size: 9))
//                                        .foregroundColor(.black)
//                                    
//                                    Text(player.isReady ? "READY": "OFFLINE")
//                                        .font(Font.custom("CircularSpUIv3T-Bold", size: 9))
//                                        .foregroundColor(player.isReady ? Color(hex: "137662") : Color(hex: "8E8E8E"))
//                                        .padding(.top, 2)
//                                }.frame(width: 45, alignment: .leading).padding(.top, -3)
//                                
//                                Image(systemName: player.isReady ? "rectangle.fill.badge.checkmark" : "rectangle.fill.badge.xmark")
//                                    .foregroundColor(player.isReady ? Color(hex: "137662") : Color(hex: "8E8E8E"))
//                                    .font(.system(size: 23))
//                            }
//                            .frame(alignment: .top)
//                            .padding(14)
//                            .background(Color.white)
//                            .cornerRadius(7)
//                            
//                            if !player.isReady {
//                                Button(action: {
//                                    // showBackAlert = true
//                                }) {
//                                    HStack(alignment: .center) {
//                                        Text("Kick")
//                                            .font(Font.custom("CircularSpUIv3T-Bold", size: 11))
//                                            .tracking(-0.25)
//                                    }
//                                    .padding(9)
//                                    .foregroundColor(Color.white)
//                                    .frame(width: 85, alignment: .top)
//                                    .background(Color(uiColor: hexStringToUIColor(hex: "707070")))
//                                    .cornerRadius(7)
//                                
//
//                                }.padding(.top, 2)
//                            }
//                        }.padding(.bottom, 10)
//                    }
//                }
//            }
//            .padding(.top, 80)
            Spacer()
            GifImageView3("cat")
                .frame(width: 130, height: 70)
            
            Text("Waiting for other players")
                .foregroundColor(Color.white)
                .padding(.top, 20)
                .font(Font.custom("CircularSpUIv3T-Book", size: 17))
            Spacer()
            
            VStack(spacing: 10) {
                VStack(spacing: 5) {
                    HStack(spacing: 0) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "B1920D")))
                            .font(.system(size: 35))
                            .padding(0)
                            .padding(.trailing, 8)
                        
                        Text("Level \(level)")
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "CFC8C1")))
                            .tracking(-0.6)
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 47))
                    }.padding(.leading, -19)
                    
                    Text("\(subcategoryName)")
                        .font(Font.custom("CircularSpUIv3T-Book", size: 19))
                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "7B7676")))
                        .tracking(-0.1)
                        .padding(.top, -6)
                    
                    Text("\(categoryName)")
                        .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "9F9999")))
                        .tracking(-0.3)
                        .font(Font.custom("CircularSpUIv3T-Bold", size: 21))
                        .padding(.top, 3)
                }.padding(.bottom, 5)
                
                if let subcategory = subcategory {
                    if let facts = subcategory.facts, !facts.isEmpty {
                        FactsView(facts: facts)                   .font(Font.custom("CircularSpUIv3T-Book", size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "797979"))
                            .padding(.horizontal, 25)
                            .padding(.bottom, 15)
                            .tracking(-0.6)
                            .frame(height: 150, alignment: .center)
                    } else{
//                        Spacer()
                        Text("").font(Font.custom("CircularSpUIv3T-Book", size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex: "797979"))
                            .padding(.horizontal, 25)
                            .padding(.bottom, 15)
                            .tracking(-0.6)
                            .frame(height: 150, alignment: .center)
                    }
                }
 
            }
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

        }.font(Font.custom("CircularSpUIv3T-Book", size: 13))
        .padding(0)
        .background(Color(hex:"202020"))
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let levelData = getLevel(by: levelId) {
                self.level = levelData.level
                fetchSubcategory(subcategoryId: levelData.subCategory)
                if let subcategoryName = getSubcategoryNameByLevelId(levelId) {
                    print("Subcategory name for \(levelId): \(subcategoryName)")
                    self.subcategoryName = subcategoryName
                } else {
                    print("No subcategory found for \(levelId)")
                }
                if let categoryName = getCategoryNameByLevelId(levelId) {
                    print("Category name for \(levelId): \(categoryName)")
                    self.categoryName = categoryName
                } else {
                    print("No category found for \(levelId)")
                }
            }
        }
    
    }
}


#Preview {
    ReadyView(levelId: "664088bd00f58b0e095eab68")
}
