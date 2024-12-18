import SwiftUI

enum AnswerState: String, Codable {
    case correctlyAnswered = "correctlyAnswered"
    case incorrectlyAnswered = "incorrectlyAnswered"
    case notAnswered = "notAnswered"
}

struct Players: Codable, Identifiable {
    let id: String
    let username: String
    let score: Int
    let isOnline: Bool
    let isMe: Bool?
    let userId: String
    let answerState: AnswerState
    let lastQuestionScore: Int
}

struct PlayerScoresView: View {
    @State private var players: [Players] = []
//        Players(
//            id: "1",
//            username: "jeevu",
//            score: 100,
//            isOnline: true,
//            isMe: false,
//            userId: "alice123",
//            answerState: .correctlyAnswered,
//            lastQuestionScore: 20
//        ),
//        Players(
//            id: "2",
//            username: "jeevu221b",
//            score: 80,
//            isOnline: true,
//            isMe: false,
//            userId: "bob456",
//            answerState: .incorrectlyAnswered,
//            lastQuestionScore: 0
//        ),
//        Players(
//            id: "3",
//            username: "logan",
//            score: 90,
//            isOnline: true,
//            isMe: false,
//            userId: "charlie789",
//            answerState: .notAnswered,
//            lastQuestionScore: 0
//        ),
//        Players(
//            id: "4",
//            username: "David",
//            score: 70,
//            isOnline: false,
//            isMe: false,
//            userId: "david104",
//            answerState: .notAnswered,
//            lastQuestionScore: 0
//        ),
//        Players(
//            id: "5",
//            username: "Navid",
//            score: 230,
//            isOnline: false,
//            isMe: false,
//            userId: "david103",
//            answerState: .correctlyAnswered,
//            lastQuestionScore: 0
//        ),
//        Players(
//            id: "6",
//            username: "Ravid",
//            score: 10,
//            isOnline: false,
//            isMe: false,
//            userId: "david102",
//            answerState: .notAnswered,
//            lastQuestionScore: 0
//        )
//    ]
    @EnvironmentObject private var socketHandler: SocketHandler
    @EnvironmentObject var AppState: Game
    var updateScoreFromSocket: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ForEach(0..<(players.count + 2) / 3, id: \.self) { rowIndex in
                HStack(alignment: .top, spacing: 8) {
                    ForEach(players[rowIndex * 3..<min((rowIndex + 1) * 3, players.count)]) { player in
                        if player.userId != AppState.user?.id {
                            PlayerScoreView(
                                playerName: player.username,
                                score: player.score,
                                answerState: player.answerState,
                                isDisconnected: !player.isOnline
                            )
                        }
                    }
                }
            }
        }
        .onAppear {
            print("here in onappear PlayerScoresView")
            let data: [String: String] = [
                "sessionId": AppState.partySession,
            ]
            socketHandler.socket.emit("getRoomUsersScore", data)
            
            socketHandler.socket.on("roomUsersScore") { [self] data, _ in
                print("roomUsersScore")
                print(data)
                if let playerArray = data[0] as? [[String: Any]] {
                    let decoder = JSONDecoder()
                    let jsonData = try? JSONSerialization.data(withJSONObject: playerArray, options: [])
                    if let jsonData = jsonData {
                        let newPlayers = try? decoder.decode([Players].self, from: jsonData)
                        DispatchQueue.main.async {
                            // Filter out the current user if their id matches AppState.user.id
                            self.players = newPlayers?.filter { $0.userId != AppState.user?.id } ?? []
                          
                            if let currentUser = newPlayers?.first(where: {
                                                $0.isMe == true && $0.userId == AppState.user?.id && $0.lastQuestionScore > 0
                                            }) {
                                                updateScoreFromSocket(currentUser.lastQuestionScore)
                                            }
                            
                        }
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
                    .foregroundColor(.white.opacity(0.7))
                    .font(Font.custom("CircularSpUIv3T-Book", size: 10))
                    .frame(width: 65, height: 38, alignment: .center)
                    .background(answerStateColor(for: answerState))
                
                Text("\(score)")
                    .tracking(-0.4)
                    .foregroundColor(.white.opacity(0.9))
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 11))
                    .frame(width: 42, height: 38, alignment: .center)
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
    PlayerScoresView(updateScoreFromSocket: { num in
        print("Update score from socket with value: \(num)")
    }).background(Color(uiColor: hexStringToUIColor(hex: "137662")))
    .environmentObject(Game())
    .environmentObject(SocketHandler())
}
