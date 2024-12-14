import SwiftUI



struct Response: Codable {
    let levelId: String
    let doesNextLevelExist: Bool
    let star: Int
    let subcategory: String
    let levels: [Level]
    let nextLevelId: String
    let requiredStars: String
    
    enum CodingKeys: String, CodingKey {
        case levelId = "levelId"
        case doesNextLevelExist = "doesNextLevelExist"
        case star = "star"
        case subcategory = "subcategory"
        case levels = "levels"
        case nextLevelId = "nextLevelId"
        case requiredStars = "requiredStars"
    }
}


func updateSession(sessionId: String, score: Binding<Int>, completion: @escaping (String, Bool, String, String, String) -> Void) {
    guard let url = URL(string: "\(baseUrl)/api/update/session") else {
        print("Invalid URL")
        completion("", false, "", "", "")
        return
    }
    
    let body: [String: Any] = [
        "userId": "6613d6eb899ff3bd6ca46608",
        "sessionId": sessionId,
        "score": score.wrappedValue <= 0 ? 0 : score.wrappedValue/10,
        "isCompleted": true
    ]
    
    print("Request Bod:")
    print(body)
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
        print("Failed to serialize request body")
        completion("", false, "", "", "")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion("", false, "", "", "")
            return
        }
        
        guard let data = data, !data.isEmpty else {
            print("Empty response data")
            completion("", false, "", "", "")
            return
        }
        
        print("Response Data:")
        print(String(data: data, encoding: .utf8) ?? "Invalid response data")
        
        do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            print("Response:")
            updateLevels(with: response.levels)
            completion(response.levelId, response.doesNextLevelExist, response.subcategory, response.nextLevelId, response.requiredStars)
        } catch {
            print("Failed to decode response: \(error.localizedDescription)")
            completion("", false, "", "", "")
        }
    }.resume()
}

struct CompleteLevelView: View {

    @Binding var score: Int
    var negativePadding = 29
    let sessionId: String
    let level: Int
    @State private var levelId: String = ""
    @State private var subcategory: String = ""
    @State private var nextLevelId: String = ""
    @State private var subcategoryName: String = ""
    @State private var requiredStars: String = ""
    @State private var doesNextLevelExist: Bool = false
    @EnvironmentObject private var navigationStore : NavigationStore
    @State var isTapped = false;
    @State var isTapped1 = false;
    
    var body: some View {
        VStack(alignment: .center){
            HStack(spacing: 0){
                Image(systemName:"bolt.fill")
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                    .font(.system(size: 18))
                    .padding(.trailing, 5)
                
                
                Text("Level \(level)")
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                    .tracking(-0.6)
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 25))
            }
            .padding(.leading, CGFloat(negativePadding))
                
                VStack{
                    Text("\(subcategoryName)").font(Font.custom("CircularSpUIv3T-Book", size: 20)).foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854"))).tracking(-0.6)
                        .opacity(0.6)
                        
                }
                .padding(.bottom, 100)
                .padding(.leading, CGFloat(negativePadding)+13)
            
            
            
            BigStarsView(stars: score >= 80 ? 3 : score > 50 ? 2 :  score > 0 ? 1 : 0)
                .padding(.leading, CGFloat(negativePadding))
            
            ScoreView(score: $score)
                .font(Font.custom("DINAlternate-Bold", size: 49))
                .foregroundStyle(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                .padding(15)
                .padding(.bottom, 0)
                .padding(.top, -40)
                .opacity(0.8)
                .padding(.leading, CGFloat(negativePadding))
            
            
            if !requiredStars.isEmpty {
                Text("\(requiredStars)").foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854"))).font(Font.custom("CircularSpUIv3T-Book", size: 17))
                    .tracking(-0.6)
                    .opacity(0.85)
                    .padding(.leading, CGFloat(negativePadding)+10)
            }
            
            
            
            GifImageView(score == 100 ? "3star" : score > 50 ? "2star" : "1star")
                .frame(width: 368, height: 155)
                .cornerRadius(7)
                .padding(.leading, CGFloat(negativePadding) + 2)
                .padding(.bottom, 5)
            
            HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTapped1.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isTapped1.toggle()
                        if doesNextLevelExist {
                            if requiredStars.isEmpty {
                                navigationStore.push(to: .screen6(nextLevelId))
                            }
                        } else {
                            navigationStore.popAllScreen6()
                            navigationStore.pop()
                            navigationStore.push(to: .screen5(subcategory))
                        }
                    }
                }) {
                    HStack {
                        if levelId.isEmpty {
                            ThreeBounceAnimation(color: .white, width: CGFloat(15), height: CGFloat(15))
                        } else{
                                Text("Next")
                                    .font(Font.custom("CircularSpUIv3T-Book", size: 20))
                                Image(systemName:"play.circle.fill")
                                .font(.system(size: 20))
                        
                        }
                    }
                    .frame(width: 90, height: 27, alignment: .center)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color(uiColor: hexStringToUIColor(hex: "DFCCC0")), lineWidth: 7)
                    )
                }
                .foregroundColor(.white)
                .background(Color(uiColor: hexStringToUIColor(hex: "D39E8B")))
                .cornerRadius(15)
                .buttonStyle(.plain)
                .padding(.bottom, 15)
                .zIndex(1)
                .scaleEffect(isTapped1 ? 1.1 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTapped1.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isTapped1.toggle()
                        if doesNextLevelExist {
                            if requiredStars.isEmpty {
                                navigationStore.push(to: .screen6(nextLevelId))
                            }
                        } else {
                            navigationStore.popAllScreen6()
                            navigationStore.pop()
                            navigationStore.push(to: .screen5(subcategory))
                        }
                    }
                }
                
                
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTapped.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isTapped.toggle()
                        navigationStore.push(to: .screen6(levelId))
                    }
                }) {
                    HStack {
                        if levelId.isEmpty {
                            ThreeBounceAnimation(color: .white, width: CGFloat(15), height: CGFloat(15))
                        } else{
                                Text("Replay")
                                    .font(Font.custom("CircularSpUIv3T-Book", size: 20))
                            Image(systemName:"arrow.clockwise.circle.fill")
                                .font(.system(size: 20))
                            
                            
                        }
                    }
                    .frame(width: 165, height: 27, alignment: .center)
                    .padding(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color(uiColor: hexStringToUIColor(hex: "9FCBB9")), lineWidth: 7)
                    )
                }
                .foregroundColor(.white)
                .background(Color(uiColor: hexStringToUIColor(hex: "21AB8F")))
                .cornerRadius(15)
                .buttonStyle(.plain)
                .padding(.bottom, 15)
                .zIndex(1)
                .scaleEffect(isTapped ? 1.1 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTapped.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        isTapped.toggle()
                        navigationStore.push(to: .screen6(levelId))
                    }
                }
            }
            .padding(.leading, CGFloat(negativePadding)+10)

            
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  alignment: .leading)
        .padding(.top, 120)
        .onAppear {
            updateSession(sessionId: sessionId, score: $score) { levelId, doesNextLevelExist, subcategory, nextLevelId, requiredStars in
                self.levelId = levelId
                self.doesNextLevelExist = doesNextLevelExist
                self.subcategory = subcategory
                self.nextLevelId = nextLevelId
                self.requiredStars = requiredStars
                if let subcategoryName = getSubcategoryNameByLevelId(levelId) {
                    print("Subcategory name for \(levelId): \(subcategoryName)")
                    self.subcategoryName = subcategoryName
                } else {
                    print("No subcategory found for \(levelId)")
                }
            }
            
            
            
        }
    }

}


//struct MyClass: View {
//    let property1: String
//    let property2: Int
//    
//    init() {
//        property1 = "Default Value"
//        property2 = 0
//        
//        for familyName in UIFont.familyNames {
//        for familyName in UIFont.familyNames {
//            print(familyName)
//            for fontName in UIFont.fontNames(forFamilyName: familyName) {
//                print("---\(fontName)")
//            }
//        }
//    }
//    
//    var body: some View{
//    Text("hello")
//    }
//}
//
//#Preview {
//    MyClass()
//}



