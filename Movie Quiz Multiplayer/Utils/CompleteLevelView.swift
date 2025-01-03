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
        case levelId, doesNextLevelExist, star, subcategory, levels, nextLevelId, requiredStars
    }
}

func updateSession(sessionId: String, score: Int, completion: @escaping (String, Bool, String, String, String) -> Void) {
    guard let url = URL(string: "\(baseUrl)/api/update/session") else {
        print("Invalid URL")
        completion("", false, "", "", "")
        return
    }
    
    let body: [String: Any] = [
        "userId": "6613d6eb899ff3bd6ca46608",
        "sessionId": sessionId,
        "score": score <= 0 ? 0 : score/10,
        "isCompleted": true
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
        print("Failed to serialize request body")
        completion("", false, "", "", "")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let user = DataManager.shared.getUser() {
        request.setValue("\(user.token ?? "")", forHTTPHeaderField: "Authorization")
    }
    
    request.httpBody = jsonData
    
    URLSession.shared.dataTask(with: request) { data, _, error in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            completion("", false, "", "", "")
            return
        }
        print(data)
        do {
            let response = try JSONDecoder().decode(Response.self, from: data)
            print(response.levels)
            updateLevels(with: response.levels)
            completion(response.levelId, response.doesNextLevelExist, response.subcategory, response.nextLevelId, response.requiredStars)
        } catch {
            print("Failed to decode response: \(error.localizedDescription)")
            completion("", false, "", "", "")
        }
    }.resume()
}

struct CompleteLevelView: View {
    @State private var isLoading = true
    let score: Int
    let negativePadding = -39
    let sessionId: String
    let level: Int
    @State private var categoryName: String = ""
    @State private var levelId = ""
    @State private var subcategory = ""
    @State private var nextLevelId = ""
    @State private var subcategoryName = ""
    @State private var requiredStars = ""
    @State private var doesNextLevelExist = false
    @EnvironmentObject private var navigationStore: NavigationStore
    @State private var isTapped1 = false
    @State private var isTapped2 = false
    @State private var isTapped3 = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("spider2")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .edgesIgnoringSafeArea(.all)
            if isLoading {
                PopcornView()
            } else {
                VStack(alignment: .center) {
                    VStack(spacing: 5) {
                        HStack(spacing: 0) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                                .font(.system(size: 25))
                                .padding(0)
                                .padding(.trailing, 5)
                            
                            Text("Level \(level)")
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                                .tracking(-0.6)
                                .font(Font.custom("CircularSpUIv3T-Bold", size: 38))
                        }.padding(.leading, -21).opacity(0.9)
                        
                        Text("\(subcategoryName)")
                            .font(Font.custom("CircularSpUIv3T-Book", size: 19))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                            .tracking(-0.1)
                            .padding(.top, -7)
                            .opacity(0.85)
                        
                        Text("\(categoryName)")
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                            .tracking(-0.3)
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 25))
                            .padding(.top, 3)
                            .opacity(0.75)
                    }.padding(.bottom, 110)
                        .padding(.leading, CGFloat(negativePadding) + 13)
                    
                    
                    
                    BigStarsView(stars: score >= 80 ? 3 : score > 50 ? 2 : score > 0 ? 1 : 0)
                        .padding(.leading, CGFloat(negativePadding))
                    
                    VStack(spacing: 20) {
                        Text("\(score)")
                            .contentTransition(.numericText())
                    }
                        .font(Font.custom("DINAlternate-Bold", size: 49))
                        .foregroundStyle(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                        .padding(15)
                        .padding(.bottom, 0)
                        .padding(.top, -40)
                        .opacity(0.8)
                        .padding(.leading, CGFloat(negativePadding))
                    
                    if !requiredStars.isEmpty {
                        Text("\(requiredStars)")
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "5C5854")))
                            .font(Font.custom("CircularSpUIv3T-Book", size: 17))
                            .tracking(-0.6)
                            .opacity(0.85)
                            .padding(.leading, CGFloat(negativePadding) + 10)
                    }
                    
                    GifImageView(score == 100 ? "3star" : score > 50 ? "2star" : "1star")
                        .frame(width: 368, height: 155)
                        .cornerRadius(7)
                        .padding(.leading, CGFloat(negativePadding) + 2)
                        .padding(.bottom, 13)
                    
                    HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isTapped1.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                withAnimation {
                                    isTapped1.toggle()
                                    if doesNextLevelExist {
                                        if requiredStars.isEmpty {
                                            navigationStore.pop()
                                            navigationStore.push(to: .screen6(nextLevelId))
                                        }
                                    } else {
                                        navigationStore.popAllScreen6()
                                        navigationStore.pop()
                                        navigationStore.push(to: .screen5(subcategory))
                                    }
                                }
                            }
                        }) {
                            HStack {
                                if levelId.isEmpty {
                                    ThreeBounceAnimation(color: .white, width: CGFloat(15), height: CGFloat(15))
                                } else {
                                    Text("Next")
                                        .font(Font.custom("CircularSpUIv3T-Bold", size: 20))
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 20))
                                }
                            }
                            .frame(width: 90, height: 27, alignment: .center)
                            .padding(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(uiColor: hexStringToUIColor(hex: "DFCCC0")).opacity(0.4), lineWidth: 7)
                            )
                        }
                        .foregroundColor(.white)
                        .background(Color(uiColor: hexStringToUIColor(hex: "D39E8B")))
                        .cornerRadius(15)
                        .buttonStyle(.plain)
                        .padding(.bottom, 15)
                        .padding(.trailing, 10)
                        .zIndex(1)
                        .scaleEffect(isTapped1 ? 1.1 : 1)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isTapped2.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                withAnimation {
                                    isTapped2.toggle()
                                    navigationStore.pop()
                                    navigationStore.push(to: .screen6(levelId))
                                }
                            }
                        }) {
                            HStack {
                                if levelId.isEmpty {
                                    ThreeBounceAnimation(color: .white, width: CGFloat(15), height: CGFloat(15))
                                } else {
                                    Text("Replay")
                                        .font(Font.custom("CircularSpUIv3T-Book", size: 20))
                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.system(size: 20))
                                }
                            }
                            .frame(width: 165, height: 27, alignment: .center)
                            .padding(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color(uiColor: hexStringToUIColor(hex: "9FCBB9")).opacity(0.4), lineWidth: 7)
                            )
                        }
                        .foregroundColor(.white)
                        .background(Color(uiColor: hexStringToUIColor(hex: "21AB8F")))
                        .cornerRadius(15)
                        .buttonStyle(.plain)
                        .padding(.bottom, 15)
                        .zIndex(1)
                        .scaleEffect(isTapped2 ? 1.1 : 1)
                    }
                    .padding(.leading, CGFloat(negativePadding) + 10)
                    
                    Spacer()
                    
                    LeaderboardButton()
                        .padding(.leading, CGFloat(negativePadding+1))
                        .padding(.bottom, -8)
                        .scaleEffect(isTapped3 ? 1.2 : 1)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isTapped3.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                withAnimation {
                                    isTapped3.toggle()
                                    navigationStore.popAllScreen6()
                                    navigationStore.pop()
                                    navigationStore.push(to: .leaderBoardPage)
                                }
                            }
                        }
                }.padding(.top, 120)

            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        .onAppear {
            updateSession(sessionId: sessionId, score: score) { levelId, doesNextLevelExist, subcategory, nextLevelId, requiredStars in
                self.levelId = levelId
                print(levelId)
                self.doesNextLevelExist = doesNextLevelExist
                self.subcategory = subcategory
                self.nextLevelId = nextLevelId
                self.requiredStars = requiredStars
                if let subcategoryName = getSubcategoryNameByLevelId(levelId) {
                    self.subcategoryName = subcategoryName
                } else {
                    print("No subcategory found for \(levelId)")
                }
                
                if let levelData = getLevel(by: levelId) {
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                    isLoading = false
                }
                
                

            }
            

        }
    }
}



struct CompleteView: PreviewProvider {
   static var previews: some View {
       CompleteLevelView(score: 50, sessionId:"664088bd00f58b0e095eab68", level: 2)
           .environmentObject(Game())
           .environmentObject(NavigationStore())
       
   }
}
