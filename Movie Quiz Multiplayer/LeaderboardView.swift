import SwiftUI
import Pow

struct LeaderboardEntry: Codable, Identifiable {
   let id = UUID()
   let userId: String
   let username: String
   let score: Int
   let stars: Int
   let currentUser: Bool?
    let climbedAt: String?
}

private func calculateFrameWidth(index: Int, containerWidth: CGFloat) -> CGFloat {
   switch index {
   case 0: return containerWidth - 5
   case 1: return containerWidth - 10
   case 2: return containerWidth - 20
   default: return containerWidth - 40
   }
}

private let darkBackgroundColor = Color(red: 23/255, green: 24/255, blue: 25/255)

        

struct LeaderboardView: View {
    @EnvironmentObject private var navigationStore: NavigationStore
    @State private var leaderboardEntries: [LeaderboardEntry] = []
    
    var containerWidth: CGFloat = UIScreen.main.bounds.width - 32.0
    
    var body: some View {
        ZStack {
            
            Image("spider4")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
           
            VStack(alignment: .center, spacing: 14) {
                Menu().padding(.trailing, -10)
                LeaderboardButtonOne().padding(.leading, 5)
//                    .padding(.top, 35)
                
                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(leaderboardEntries.indices, id: \.self) { index in
                            let entry = leaderboardEntries[index]
                            
                            VStack {
                                HStack{
                                    if let currentUser = entry.currentUser, currentUser {
                                        Text("\(index + 1)")
                                            .font(Font.custom("DINAlternate-Bold", size: 14))
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "137662")))
                                            .frame(width: 20, height: 20)
                                            .background(index != 0 ? Color(uiColor: hexStringToUIColor(hex: "FFDA40")) : .white)
                                            .cornerRadius(50)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(Font.custom("DINAlternate-Bold", size: 14))
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "137662")))
                                            .frame(width: 20, height: 20)
                                            .background(index != 0 ? Color(uiColor: hexStringToUIColor(hex: "D9D9D9")) : .white)
                                            .cornerRadius(50)
                                    }

                                    if let currentUser = entry.currentUser, currentUser {
                                             Text("\(entry.username) (me)")
                                                 .font(Font.custom(index == 0 ? "CircularSpUIv3T-Bold" : "CircularSpUIv3T-Book", size: index == 0 ? 17 : 14))
                                                 .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "FFDA40")))
                                         } else {
                                             Text(entry.username)
                                                 .font(Font.custom(index == 0 ? "CircularSpUIv3T-Bold" : "CircularSpUIv3T-Book", size: index == 0 ? 17 : 14))
                                         }
                                         
                                  
                                    Spacer()
                                    
                                    HStack(spacing: 2) {
                                        Image("filledstar")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 22, height: 22, alignment: .center)
                                            .padding(.trailing, 4)
                                        
                                        Text("\(entry.stars)")
                                            .font(Font.custom("DINAlternate-Bold", size: 22))
                                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "FFDA40")))
                                            .tracking(-0.6)
                                            .padding(.trailing, 6)
                                    }
                                }
                                
                                HStack{
                                    if let climbedAtString = entry.climbedAt {
                                        ZStack{
                                            TimeCounter(utcDateString: climbedAtString)
                                        }.padding(.top, 5)
                                            .padding(.bottom, -5)
                                    } else {
                                        // Handle the case when climbedAt is nil
                                    }
                                }
                                

                            }                            .padding(22)
                            .background(Color(uiColor: hexStringToUIColor(hex: "359D88")).opacity(index >= 3 ? 0.87 : 0.97))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: index == 0 ? 18 : 40))
                            .overlay(
                                RoundedRectangle(cornerRadius: index == 0 ? 18 : 40)
                                    .stroke(Color(uiColor: hexStringToUIColor(hex: "E6D2A7")), lineWidth: index == 0 ? 2 : 0)
                            )
                            .frame(width: calculateFrameWidth(index: index, containerWidth: containerWidth), alignment: .center)
                            .padding(5)
                            .conditionalEffect(
                                .repeat(
                                    .glow(color: .white, radius: 130),
                                  every: 1
                                ),
                                condition: entry.currentUser ?? false
                            )

                        }
                    }
                    .padding(.bottom)
                }
            }
            .frame(width: containerWidth)
            .padding(.top, -10)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchLeaderboardData()
        }
    }
   
    private func fetchLeaderboardData() {
        guard let url = URL(string: "\(baseUrl)/api/get/leaderboard") else {
            return
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add the token to the Authorization header
        if let user = DataManager.shared.getUser() {
            print(user.token)

            request.setValue("\(user.token ?? "")", forHTTPHeaderField: "Authorization")
        }
        
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            
            do {
                let entries = try JSONDecoder().decode([LeaderboardEntry].self, from: data)
                print(entries)
                DispatchQueue.main.async {
                    leaderboardEntries = entries
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
}





#Preview {
   LeaderboardView()
        .environmentObject(Game())

}
