import SwiftUI
import NotificationCenter
import Pow
import Combine
import SystemNotification
import UIKit


class RoomUsers: ObservableObject {
    @Published var users: [Player] = []
}

class PartyDataModel: ObservableObject {
    @Published var levelName: String = "..."
    @Published var categoryName: String = "..."
    @Published var subcategoryName: String = "..."
    @Published var levelId: String = ""
}

struct PartyView: View {
    @EnvironmentObject private var socketHandler: SocketHandler
    @StateObject private var roomUsers = RoomUsers()
    @State private var isTapped = false
    @State private var isActive = false
    @StateObject private var partyDataModel = PartyDataModel()
    @State private var showBackAlert = false
    @EnvironmentObject private var navigationStore : NavigationStore
    @EnvironmentObject var AppState: Game
    @State private var showDisconnectAlert = false


    var isCurrentUserHost: Bool {
        print(AppState.user)
        print(roomUsers.users)
        if let hostUser = roomUsers.users.first(where: { $0.isHost }),
           let currentUser = AppState.user,
           hostUser.id == currentUser.id {
            if !AppState.isHost {
                print("setting ishost true")
                AppState.isHost = true
            }
            return true
            
        }
        if AppState.isHost {
            print("setting ishost false")
            AppState.isHost = false
        }
        return false
    }
    
    
    var hostUsername: String {
        if let host = roomUsers.users.first(where: { $0.isHost }) {
            return host.username
        }
        return ""
    }


    
    var body: some View {
        VStack(alignment: .leading) {
            // Party Header
            Menu().padding(.top, 40)
            VStack(alignment: .leading) {
                    Text(isCurrentUserHost ? "Your party" : "\(hostUsername)'s party")
                        .font(Font.custom("CircularSpUIv3T-Bold", size: 30))
                        .tracking(-0.7)
                        .foregroundColor(Color(hexStringToUIColor(hex: "2C2929")))
                
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
            .padding(.leading, 5)
            
            // Category Box
            ZStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Category:")
                                .font(Font.custom("CircularSpUIv3T-Book", size: 14))
                                .tracking(-0.25)
                                .padding(0)
                            Text(partyDataModel.categoryName).font(Font.custom("CircularSpUIv3T-Bold", size: 14))
                                .padding(.leading, -5)
                                .tracking(-0.25)
                        }
                        .foregroundColor(.black)
                        .padding(.bottom, 3)

                        HStack {
                            Text("Sub category:")
                                .font(Font.custom("CircularSpUIv3T-Book", size: 14))
                                .tracking(-0.25)
                            Text(partyDataModel.subcategoryName).font(Font.custom("CircularSpUIv3T-Bold", size: 14)).tracking(-0.25)
                        }
                        .foregroundColor(.black)
                        .padding(.bottom, 3)

                        HStack {
                            Text("Level")
                                .font(Font.custom("CircularSpUIv3T-Book", size: 14))
                                .tracking(-0.25)
                            Text(partyDataModel.levelName).font(Font.custom("CircularSpUIv3T-Bold", size: 14))
                                .tracking(-0.45)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.leading, 5)
                    .frame(alignment: .leading)
                    .foregroundColor(Color(hexStringToUIColor(hex: "2C2929")))
                    
                    ZStack {
                        Image("motif")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 10, height: 130)
                            .padding(.leading, 205)
                            .padding(.top, -100)
                    }
                }
            }
            .font(Font.custom("CircularSpUIv3T-Bold", size: 20))
            .frame(width: 250, height: 100, alignment: .leading)
            .padding()
            .background(Color(uiColor: hexStringToUIColor(hex: "F1F1F1")))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.20), lineWidth: 15)
            )
            .padding(.horizontal)
            
            // Buttons
            HStack(alignment: .center) {
                Button(action: {
                    // Invite friends action
                }) {
                    HStack(alignment: .center) {
                        Image(systemName:"clipboard.fill")
                            .resizable()
                            .foregroundColor(Color(red: 175/255, green: 205/255, blue: 208/255))
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .padding(.trailing, -5)
                            .offset(x: 0, y: -1)
                        Text("Copy party code")
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 11))
                            .tracking(-0.25)
                            .offset(x: 0, y: -1)
                    }
                    .padding(11)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "414141")))
                    .frame(width: 133, alignment: .center)
                    .background(Color(uiColor: hexStringToUIColor(hex: "F7F6F6")))
                    .cornerRadius(7)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.20), lineWidth: isTapped ? 8 : 5)
                    )
                    .onTapGesture {
                        isTapped.toggle()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            UIPasteboard.general.string = AppState.partySession
                            isActive.toggle()
                            isTapped.toggle()
                        }
                    }
                }
                .padding(.trailing, 7)
                
                Button(action: {
                    showBackAlert = true
                }) {
                    HStack(alignment: .center) {
                        Text("Leave")
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 11))
                            .tracking(-0.25)
                    }
                    .padding(11)
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "616262")))
                    .frame(width: 80, alignment: .center)
                    .background(Color(uiColor: hexStringToUIColor(hex: "E6ECED")))
                    .cornerRadius(7)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.20), lineWidth: 5)
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 13)
            .padding(.bottom, 23)
            .padding(.leading, 7)
            
            // Players
            HStack{
                
                Text("Players")
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 30))
                    .tracking(-0.7)
                    .padding(.horizontal)
                    .padding(.leading, 5)
                    .foregroundColor(Color(hexStringToUIColor(hex: "2C2929")))
//                if roomUsers.users.count > 1 { Text("\(roomUsers.users.count)").font(Font.custom("DINAlternate-Bold", size: 30))
//                        .tracking(-0.7)
//                        .padding(.leading, -15)
//                        .foregroundColor(Color(hexStringToUIColor(hex: "2C2929")).opacity(0.2))
//                }
            }
            
            ScrollView {
                GridView(players: roomUsers.users)
                    .padding(.horizontal)
            }
            .padding(.bottom)
            
        }
        .onAppear {
            var photoURL = ""
            var name = ""
            if let user = DataManager.shared.getUser() {
                name = user.username ?? "santo"
                if let url = user.photoURL {
                    photoURL = url.absoluteString
                }
            }
            let data: [String: String] = [
                "username": name,
                "sessionId":  AppState.partySession,
                "room": "test",
                "photoURL": photoURL
            ]
            socketHandler.socket.emit("joinRoom", data)
            
            NotificationCenter.default.addObserver(forName: .roomUsersUpdated, object: nil, queue: .main) { notification in
                if let data = notification.object as? [Any] {
                    var newUsers: [Player] = []
                    if let userArrays = data as? [NSArray] {
                        for userArray in userArrays {
                            for userDict in userArray {
                                if let userDict = userDict as? [String: Any], let id = userDict["userId"] as? String {
                                    let player = Player(
                                        username: userDict["username"] as? String ?? "",
                                        score: userDict["score"] as? Int ?? 0,
                                        rank: userDict["rank"] as? Int ?? 0,
                                        lastRound: userDict["lastRound"] as? Int ?? 0,
                                        imageName: userDict["imageName"] as? String ?? "",
                                        isOnline: userDict["isOnline"] as? Bool ?? false,
                                        id: userDict["userId"] as? String ?? "",
                                        isHost: userDict["isHost"] as? Bool ?? false
                                    )
                                    newUsers.append(player)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        roomUsers.users = newUsers
                    }
                }
            }
            
            socketHandler.socket.on("partyData") { data, ack in
                print("partyData")
                print(data)
                if let dataDict = data[0] as? [String: String],
                   let name = dataDict["name"],
                   let value = dataDict["value"],
                   let id = dataDict["id"] {
                    DispatchQueue.main.async {
                        switch id {
                        case "level":
                            self.partyDataModel.levelName = name
                            self.partyDataModel.levelId = value
                        case "category":
                            self.partyDataModel.categoryName = name
                        case "subcategory":
                            self.partyDataModel.subcategoryName = name
                        default:
                            break
                        }
                    }
                }
            }
            
            socketHandler.socket.on("prepareForGame") { data, ack in
                print("prepareForGame")
                if !AppState.isHost {
                    navigationStore.popAllLobby()
                    navigationStore.popAllScreen7()
                    navigationStore.push(to: .screen7(self.partyDataModel.levelId))
                }
         
            }
            
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .roomUsersUpdated, object: nil)

        }
        .alert(isPresented: $showBackAlert) {
            Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to leave the party?"),
                primaryButton: .default(Text("Stay"), action: {
                    showBackAlert = false
                }),
                secondaryButton: .destructive(Text("Leave"), action: {
                    AppState.isHost = false
                    AppState.inParty = false
                    socketHandler.leaveRoom(sessionId: AppState.partySession)
                    AppState.partySession = ""
                    navigationStore.popToRoot()
                    navigationStore.push(to: .screen3)
                })
           )
       }
        .background(Color(red: 175/255, green: 205/255, blue: 208/255))
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .systemNotification(isActive: $isActive) {
            SystemNotificationContent2()
        }
    }
}

struct Player {
    let username: String
    let score: Int
    let rank: Int
    let lastRound: Int
    let imageName: String
    let isOnline: Bool
    let id: String
    let isHost: Bool
}

struct GridView: View {
    let players: [Player]
    
    var body: some View {
        VStack {
            ForEach(0..<(players.count + 1) / 2, id: \.self) { row in
                HStack {
                    ForEach(0..<2, id: \.self) { col in
                        let index = row * 2 + col
                        if index < players.count {
                            PlayerView(player: players[index]).padding(7)
                        } else {
                            EmptyPlayerView().padding(0)
                        }
                    }
                }
            }
            Spacer()
            Spacer()
            Spacer()
            Spacer()
        }
    }
}
struct EmptyPlayerView: View {
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                VStack {
                    VStack {
                        // Empty placeholder for crown image
                        Color.clear
                            .frame(width: 33, height: 33)
                            .padding(.bottom, -10)
                            .padding(.leading, 15)
                        
                        // Empty placeholder for player image
                        Color.clear
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    .padding(.top, 0)
                    
                    // Empty placeholders for player details
                    Color.clear.frame(height: 5)
                    Color.clear.frame(height: 5)
                    Color.clear.frame(height: 5)
                    Color.clear.frame(height: 5)
                }
            }
            
            ZStack {
                // Empty placeholder for motif image
                Color.clear
                    .frame(width: 160, height: 160, alignment: .leading)
                    .padding(.top, -195)
                    .padding(.leading, -160)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")))
        .cornerRadius(15)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.40), lineWidth: 9)
        )
        .opacity(0)
    }
}

struct PlayerView: View {
    let player: Player
    @State var isTapped = false
    @EnvironmentObject var AppState: Game

    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                VStack {
                    VStack {
                        if player.rank > 0 {
                            //put this inside a view and apply this effect
                            //.changeEffect(.jump(height: 100), value: count)
                            PlayerRankView(player: player)
                            .zIndex(2)
                        }
                        
                        AsyncImage(url: URL(string: player.imageName)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .padding(.top, 5)
                    
                    HStack {
                        // show "You" if the player is the current user
                        Text(AppState.user?.id == player.id ? "You" : player.username)
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 15))
                            .padding(.trailing, 0)
                            .foregroundColor(Color(hexStringToUIColor(hex: "2C2929")))
                            .tracking(-0.4)
                        
                        Circle()
                            .fill(player.isOnline ? Color(hexStringToUIColor(hex: "3CF465")).opacity(0.4) : Color.gray)
                            .frame(width: 5, height: 5)
                            .offset(x: 0, y: 1)
                            .padding(.leading, -3)
                        
                        Text(player.isOnline ? "online" : "offline")
                            .font(Font.custom("CircularSpUIv3T-Book", size: 12))
                            .foregroundColor(Color(hexStringToUIColor(hex: "A5A5A5")))
                            .padding(.leading, -6)
                            .tracking(-0.4)
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 1)
                    
                    HStack {
                        Text("Score:")
                            .padding(.trailing, 0)
                            .foregroundColor(Color(hexStringToUIColor(hex: "A5A5A5")))
                            .tracking(-0.4)
                        Text("\(player.score)")
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 13))
                            .foregroundColor(Color(hexStringToUIColor(hex: "2C2929")))
                            .padding(.leading, -6)
                        
                        Text("Rank:")
                            .foregroundColor(Color(hexStringToUIColor(hex: "A5A5A5")))
                            .tracking(-0.4)
                        Text("\(player.rank)")
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 14))
                            .foregroundColor(Color(hexStringToUIColor(hex: "2C2929")))
                            .padding(.leading, -6)
                    }
                    .font(Font.custom("CircularSpUIv3T-Book", size: 13))
                    .padding(.bottom, 1)
                    
                }
            }
            
            ZStack {
                Image("motif")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160, alignment: .leading)
                    .padding(.top, -195)
                    .padding(.leading, -160)
                    .rotationEffect(.degrees(22), anchor: .center)
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Color(uiColor: hexStringToUIColor(hex: isTapped ? "EAFDFF" : player.rank == 1 ? "FFF9E8": "FFFFFF")))
        .cornerRadius(15)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(uiColor: hexStringToUIColor(hex: player.rank == 1 ? "F9EDCC": "FFFFFF")).opacity(0.40), lineWidth: isTapped ? 17 : 14)
        )
        .onTapGesture {
            isTapped.toggle()
            withAnimation(.easeInOut(duration: 0.25)) {
                isTapped.toggle()
            }
        }
    }
}


struct PlayerRankView: View {
    var player: Player
    @State private var count: Int = 0
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if player.rank <= 3 {
                Image(player.rank == 1 ? "goldcrown" : player.rank == 2 ? "silvercrown" : "bronzecrown")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 47, height: 47)
                    .padding(.bottom, -15)
                    .padding(.top, -15)
                    .padding(.leading, 15)
                    .rotationEffect(.degrees(12), anchor: .center)
                    .zIndex(2)
            } else {
                Image("cry")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 47, height: 47)
                    .padding(.bottom, -15)
                    .padding(.leading, 15)
                    .zIndex(2)
            }
        }
        .changeEffect(.jump(height: 8), value:  player.rank <= 2 ? count : 0) // Apply the custom effect
        .onReceive(timer) { _ in
            count += 1
        }
    }
}


#Preview {
    PartyView()
        .environmentObject(NavigationStore())
        .environmentObject(Game())
        .environmentObject(SocketHandler())
}
