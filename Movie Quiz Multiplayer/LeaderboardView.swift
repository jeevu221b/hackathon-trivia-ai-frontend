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

struct MainTabs: View {
    @Binding var selectedTab: String
    @Namespace private var animationNamespace
    
    var body: some View {
        ZStack {
            // Background container
            RoundedRectangle(cornerRadius: 55)
                .fill(Color(uiColor: hexStringToUIColor(hex: "6F1612")).opacity(0.95))
                .frame(height: 70)
            
            // Animated selection background
            GeometryReader { geometry in
                let tabWidth = (geometry.size.width - 10) / 2 // Adjust for padding
                
                HStack(spacing: 0) {
                    if selectedTab == "All time" {
                        Spacer().frame(width: tabWidth + 10) // Move the background to the right
                    }
                    
                    RoundedRectangle(cornerRadius: 55)
                        .fill(Color.white)
                        .frame(width: tabWidth, height: 70 - 20) // Adjust for padding
                        .matchedGeometryEffect(id: "background", in: animationNamespace)
                    
                    Spacer()
                }
            }
            .padding(10)
            .allowsHitTesting(false) // Disable interaction with the animated background
            
            // Foreground tabs
            HStack(spacing: 0) {
                TabItem(title: "This week", isSelected: selectedTab == "This week") {
                    withAnimation(.spring()) {
                        selectedTab = "This week"
                    }
                }
                TabItem(title: "All time", isSelected: selectedTab == "All time") {
                    withAnimation(.spring()) {
                        selectedTab = "All time"
                    }
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: 70)
        }
        .frame(maxWidth: .infinity, maxHeight: 70)
    }
}

struct TabItem: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font.custom("CircularSpUIv3T-Bold", size: 15))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(isSelected ? Color.black : Color.white)
                .background(Color.clear) // Transparent background to allow button to take full space
                .cornerRadius(55)
        }
        .buttonStyle(PlainButtonStyle()) // Optional: Makes the button style plain without any default button styling
    }
}

struct LeaderboardView: View {
    @EnvironmentObject private var navigationStore: NavigationStore
    @State private var allEntries: [LeaderboardEntry] = []
    @State private var weeklyEntries: [LeaderboardEntry] = []
    @State private var selectedTab: String = "This week"
    
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
                
                VStack {
                    MainTabs(selectedTab: $selectedTab)
                }
                
                let leaderboardEntries = selectedTab == "This week" ? weeklyEntries : allEntries
                
                ScrollView {
                    VStack(spacing: 5) {
                        ForEach(leaderboardEntries.indices, id: \.self) { index in
                            let entry = leaderboardEntries[index]
                            LeaderboardRow(entry: entry, index: index, containerWidth: containerWidth)
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
                let response = try JSONDecoder().decode([String: [LeaderboardEntry]].self, from: data)
                print(response)
                DispatchQueue.main.async {
                    allEntries = response["all"] ?? []
                    weeklyEntries = response["weekly"] ?? []
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let index: Int
    let containerWidth: CGFloat
    
    var body: some View {
        VStack {
            HStack {
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
            
            if let climbedAtString = entry.climbedAt {
                ZStack {
                    TimeCounter(utcDateString: climbedAtString)
                }
                .padding(.top, 5)
                .padding(.bottom, -5)
            }
        }
        .padding(22)
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

#Preview {
    LeaderboardView()
        .environmentObject(Game())
}
