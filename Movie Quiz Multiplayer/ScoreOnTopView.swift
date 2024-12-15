import SwiftUI
struct Players: Encodable, Decodable, Identifiable {
    let id: String
    let username: String
    let score: Int
    let lastRound: Int
    let rank: Int
    let isOnline: Bool
    let userId: String
}

struct PlayerScoresView: View {
    @State private var players: [Players] = []
    @EnvironmentObject private var socketHandler: SocketHandler
    @EnvironmentObject var AppState: Game
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(players) { player in
                PlayerScoreView(
                    playerName: player.username,
                    score: player.score,
                    answerState: player.lastRound > 0 ? .correctlyAnswered : .notAnswered,
                    isDisconnected: !player.isOnline
                )
            }
        }.onAppear {
            print("here in onappear PlayerScoresView")
            let data: [String: String] = [
                "sessionId": "sessionId",
            ]
            socketHandler.socket.emit("getRoomUsers", data)
            
            socketHandler.socket.on("roomUsersScore") { [self] data, _ in
                if let playerArray = data[0] as? [[String: Any]] {
                    var newPlayers: [Players] = []
                    for playerData in playerArray {
                        let player = Players(
                            id: playerData["id"] as? String ?? "",
                            username: playerData["username"] as? String ?? "",
                            score: playerData["score"] as? Int ?? 0,
                            lastRound: playerData["lastRound"] as? Int ?? 0,
                            rank: playerData["rank"] as? Int ?? 0,
                            isOnline: playerData["isOnline"] as? Int == 1,
                            userId: playerData["userId"] as? String ?? ""
                        )
                        newPlayers.append(player)
                    }
                    DispatchQueue.main.async {
                        self.players = newPlayers
                    }
                }
            }
        }
    }
}

struct PlayerScoreView: View {
    let playerName: String
    let score: Int
    let answerState: AnswerState
    let isDisconnected: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(playerName)
                    .tracking(-0.4)
                    .foregroundColor(.white.opacity(0.6))
                    .font(Font.custom("CircularSpUIv3T-Book", size: 9))
                    .frame(width: 75, height: 42, alignment: .center)
                    .background(Color(answerStateColor(for: answerState)))
                
                Text("\(score)")
                    .tracking(-0.4)
                    .foregroundColor(.white.opacity(0.8))
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 10))
                    .frame(width: 37, height: 42, alignment: .center)
                    .padding(.leading, -8)
            }
            .padding(0)
            .background(Color(hex: "095445"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if isDisconnected {
                VStack {
                    HStack(alignment: .center) {
                        Circle()
                            .fill(Color(hex: "4C8D80"))
                            .frame(width: 7, height: 7)
                            .padding(.leading, 0)
                            .offset(x: 0, y: 1)
                        
                        Text("offline")
                            .font(Font.custom("CircularSpUIv3T-Book", size: 10))
                            .foregroundColor(Color(hex: "74AFA2"))
                            .padding(.leading, -5)
                    }
                }
            }
        }
    }
    
    private func answerStateColor(for state: AnswerState) -> Color {
        switch state {
        case .correctlyAnswered:
            return Color(hex: "1C9E85")
        case .incorrectlyAnswered:
            return Color(hex: "AD7470")
        case .notAnswered:
            return Color(hex: "155C4E")
        }
    }
}

enum AnswerState {
    case correctlyAnswered
    case incorrectlyAnswered
    case notAnswered
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}


#Preview {
    PlayerScoresView()
        .environmentObject(Game())
}
