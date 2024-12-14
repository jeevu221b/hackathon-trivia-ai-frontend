import SwiftUI

struct LeaderboardEntry: Codable, Identifiable {
   let id = UUID()
   let userId: String
   let username: String
   let score: Int
   let stars: Int
}

private func calculateFrameWidth(index: Int, containerWidth: CGFloat) -> CGFloat {
   switch index {
   case 0: return containerWidth
   case 1: return containerWidth - 10
   case 2: return containerWidth - 20
   default: return containerWidth - 40
   }
}

struct LeaderboardView: View {
   @EnvironmentObject private var navigationStore: NavigationStore
   @State private var leaderboardEntries: [LeaderboardEntry] = []
   
   var containerWidth: CGFloat = UIScreen.main.bounds.width - 32.0
   
   var body: some View {
       ZStack {
           Image("spider")
               .resizable()
               .scaledToFill()
               .edgesIgnoringSafeArea(.all)
           
           VStack(alignment: .center, spacing: 14) {
               LeaderboardButtonOne()
               
               ForEach(leaderboardEntries.indices, id: \.self) { index in
                   let entry = leaderboardEntries[index]
                   
                   HStack {
                       Text("\(index + 1)")
                           .font(Font.custom("DINAlternate-Bold", size: 16))
                           .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "73A4A9")))
                           .frame(width: 23, height: 23)
                           .background(index != 0 ? Color(uiColor: hexStringToUIColor(hex: "D9D9D9")) : .white)
                           .cornerRadius(50)
                       
                       Text(entry.username)
                           .font(Font.custom(index == 0 ? "CircularSpUIv3T-Bold" : "CircularSpUIv3T-Book", size: 19))
                       
                       Spacer()
                       
                       HStack(spacing: 2) {
                           Image("filledstar")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 25, height: 25, alignment: .center)
                               .padding(.trailing, 4)
                           
                           Text("\(entry.stars)")
                               .font(Font.custom("DINAlternate-Bold", size: 27))
                               .tracking(-0.6)
                               .padding(.trailing, 6)
                       }
                   }
                   .padding(12)
                   .background(Color(uiColor: hexStringToUIColor(hex: "73A4A9")))
                   .cornerRadius(40)
                   .foregroundColor(.white)
                   .clipShape(RoundedRectangle(cornerRadius: 40))
                   .overlay(
                       RoundedRectangle(cornerRadius: 40)
                           .stroke(Color(uiColor: hexStringToUIColor(hex: "E6D2A7")), lineWidth: index == 0 ? 4 : 0)
                   )
                   .frame(width: calculateFrameWidth(index: index, containerWidth: containerWidth), alignment: .center)
                   .opacity(index >= 3 ? 0.8 : 1)
               }
               
               Spacer()
           }
           .frame(width: containerWidth)
           .padding(.top, 40)
       }
       .navigationBarBackButtonHidden(true)
       .onAppear {
           fetchLeaderboardData()
       }
   }
   
   private func fetchLeaderboardData() {
       guard let url =  URL(string: "\(baseUrl)/api/get/leaderboard") else {
           return
       }
       
       print(url)
       var request = URLRequest(url: url)
       request.httpMethod = "GET"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
       URLSession.shared.dataTask(with: request) { data, _, error in
           if let error = error {
               print("Error: \(error.localizedDescription)")
               return
           }
           
           guard let data = data else {
               print("No data received")
               return
           }
           print(data)
           do {
               let entries = try JSONDecoder().decode([LeaderboardEntry].self, from: data)
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
