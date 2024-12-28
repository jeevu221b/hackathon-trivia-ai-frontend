import SwiftUI
import SystemNotification
import UIKit
// Helper function to randomly pick an image name
func getRandomImageName() -> String {
    let imageNames = ["flame.fill", "fireworks", "laser.burst", "party.popper.fill", "flame.circle.fill"]
    return imageNames.randomElement() ?? "flame.fill"
}


func isValidObjectId(_ objectId: String) -> Bool {
        let objectIdRegex = "^[0-9a-fA-F]{24}$"
        let objectIdTest = NSPredicate(format: "SELF MATCHES %@", objectIdRegex)
        return objectIdTest.evaluate(with: objectId)
    }

struct PartyBox: View {
    @State var isTapped = false
    @EnvironmentObject var AppState: Game
    
    func changeIsTapped(){
        isTapped.toggle()
    }
    
    var body: some View {
        if AppState.inParty {
            PartyCreatedView().frame(height: 121)
               
        } else{
            CreatePartyView(changeIsTapped: changeIsTapped).frame(height: 121)
               
        }
        
    }
}
    
    
    
    
struct CreatePartyView: View {
    let changeIsTapped: () -> Void
    @State var isTapped = false
    @State var isTapped2 = false
    @EnvironmentObject var AppState: Game
    @EnvironmentObject private var navigationStore : NavigationStore
    @State private var isActive = false
    @State private var isActive2 = false
    @State private var isActive3 = false
    @EnvironmentObject private var socketHandler: SocketHandler


    
    var body: some View {
        VStack{
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create your own party!")
                        .font(.custom("CircularSpUIv3T-Bold", size: 16))
                        .foregroundColor(Color.black)
                        .tracking(-0.5)
                        .padding(.top, 3)
                    
                    Text("And invite your friends and family to play together")
                        .font(.custom("CircularSpUIv3T-Book", size: 10))
                        .foregroundColor(Color(hex:"1B1A1A"))
                        .tracking(-0.2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, -6)
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .padding(0)
                .padding(.leading, 5)
                
                HStack{
                    VStack {
                        Button(action: {
                            // Start a party action
                        }) {
                            HStack {
                                if isTapped {
                                    ThreeBounceAnimation(color: .black,
                                                         width: CGFloat(20), height: CGFloat(20))
                                    .frame(width: 60, height: 20)
                                    .padding(.leading, 10)
                                    .padding(.trailing, 10)
                                } else {
                                    
                                    Image("party")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    Text("Start a party")
                                        .font(.custom("CircularSpUIv3T-Bold", size: 12))
                                        .foregroundColor(Color.black)
                                        .padding(.leading, -3)
                                }
                            }
                            .padding(7)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .background(Color.white)
                            .cornerRadius(7)
                            .fixedSize(horizontal: true, vertical: false)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.40), lineWidth: isTapped ? 15 : 4)
                                    .rotationEffect(.degrees(0), anchor: .center)
                                
                            )
                            .onTapGesture {
                                isTapped.toggle()
                                if !socketHandler.isConnected{
                                    isActive2.toggle()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        isTapped.toggle()
                                    }
                                    return
                                }
                                var sessionId = ""
                                Task {
                                    sessionId = await createSession(levelId: "", multiplayer: true) ?? ""
                                }
                                print("party ID")
                                print(sessionId)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if !AppState.isMultiplayer {
                                        AppState.isMultiplayer = true
                                    }
                                    AppState.inParty = true
                                    AppState.partySession = sessionId
                                    AppState.isHost = true
                                    isTapped.toggle()
                                    navigationStore.push(to: .lobbyView)
                                    
                                }
                                
                            }
                            .padding(.top, 5)
                            
                            // Ensure the button does not break
                        }
                        .padding(.trailing, 10)
                        
                    }
                    
                    VStack{
                        Button(action: {
                            if !socketHandler.isConnected{
                                isTapped2.toggle()
                                isActive3.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    isTapped2.toggle()
                                }
                                return
                            }
                            if let clipboardContent = UIPasteboard.general.string, isValidObjectId(clipboardContent) {
                                isTapped2.toggle()
                                print("clipboard")
                                    isTapped2.toggle()
                                    print(clipboardContent)
                                    AppState.inParty = true
                                    AppState.partySession = clipboardContent
                                    if !AppState.isMultiplayer {
                                        AppState.isMultiplayer = true
                                    }
                                    navigationStore.push(to: .lobbyView)
//                                }
                            } else {
                                isTapped2.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    isTapped2.toggle()
                                    isActive.toggle()
                                }
                                print("No content in clipboard")
                            }
                        }) {
                            HStack {
                                    Image(systemName:"clipboard.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(red: 175/255, green: 205/255, blue: 208/255))
                                    Text("Paste a party code")
                                        .tracking(-0.1)
                                        .font(.custom("CircularSpUIv3T-Bold", size: 12))
                                        .foregroundColor(Color.black)
                                        .padding(.leading, -3)
                                
                            }
                            .padding(9.3)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .background(Color.white)
                            .cornerRadius(7)
                            .fixedSize(horizontal: true, vertical: false)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.40), lineWidth: isTapped2 ? 15 : 4)
                                    .rotationEffect(.degrees(0), anchor: .center)
                                
                            )
//                            .onTapGesture
                            .padding(.top, 5)
                            
                            // Ensure the button does not break
                        }
                        .padding(.trailing, 1)
                        
                    }
                }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
            }.padding(15)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(
                ZStack{
                    Image("motif2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150, alignment: .leading).padding(.leading, -250)
                        .zIndex(2)
                        .rotationEffect(.degrees(5), anchor: .center)
                        .opacity(0.2)
            }
            )
            .background(Color(red: 175/255, green: 205/255, blue: 208/255))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(uiColor: hexStringToUIColor(hex: "444E50")), lineWidth: 10)
                
            )
            .cornerRadius(15)
            
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .systemNotification(isActive: $isActive) {
                SystemNotificationContent3()
            }
            .systemNotification(isActive: $isActive2) {
                SystemNotificationContent5()
            }
            .systemNotification(isActive: $isActive3) {
                SystemNotificationContent6()
            }
            
    
    }
}

struct SystemNotificationContent2: View {
    var body: some View {
        HStack {
            Image(systemName: "clipboard.fill")
                .font(.system(size: 15))
                .padding(.trailing, -45)
                .padding(.leading, 17)
            Text("Party code copied")
                .font(.custom("CircularSpUIv3T-Bold", size: 12))
                .padding(.leading, 5)
                .padding(15)
        }
    }
}

struct StreakNotification: View {
    var text: String
    var imageName: String
    private let darkBackgroundColor = Color(red: 23/255, green: 24/255, blue: 25/255)
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .font(.system(size: 15))
                .foregroundColor(darkBackgroundColor)
                .padding(.trailing, -45)
                .padding(.leading, 17)
            Text(text)
                .font(.custom("CircularSpUIv3T-Bold", size: 12))
                .padding(.leading, 5)
                .padding(15)
        }
    }
}

struct SystemNotificationContent3: View {
    var body: some View {
            HStack{
                Image(systemName: "clipboard.fill")
                    .font(.system(size: 15))
                    .padding(.trailing, -45)
                    .padding(.leading, 17)
                Text("Invalid party code")
                    .font(.custom("CircularSpUIv3T-Bold", size: 12))
                    .padding(.leading, 5)
                    .padding(15)
            
        }
    }
}





struct SystemNotificationContent5: View {
    var body: some View {
            HStack{
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15))
                    .padding(.trailing, -45)
                    .padding(.leading, 17)
                Text("Could not create a party")
                    .font(.custom("CircularSpUIv3T-Bold", size: 12))
                    .padding(.leading, 5)
                    .padding(15)
            
        }
    }
}

struct SystemNotificationContent6: View {
    var body: some View {
            HStack{
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15))
                    .padding(.trailing, -45)
                    .padding(.leading, 17)
                Text("Could not join the party")
                    .font(.custom("CircularSpUIv3T-Bold", size: 12))
                    .padding(.leading, 5)
                    .padding(15)
            
        }
    }
}





struct PartyCreatedView: View {
    @State var isTapped = false
    @State var isTapped2 = false
    @EnvironmentObject var AppState: Game
    @State private var isActive = false
    @EnvironmentObject private var navigationStore : NavigationStore
//    @EnvironmentObject private var socketHandler: SocketHandler



    var body: some View {
        VStack{
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("You are in a party!")
                        .font(.custom("CircularSpUIv3T-Bold", size: 16))
                        .foregroundColor(Color.black)
                        .tracking(-0.5)
                        .padding(.top, 3)
                    
                    HStack {
                        ForEach(AppState.roomUsers, id: \.id) { user in
                            AsyncImage(url: URL(string: user.imageName)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 25, height: 25)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    
                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .padding(0)
                .padding(.leading, 5)
                
                HStack{
                    VStack{
                        Button(action: {
                               
                            
                        }) {
                            HStack {
                                Image("party")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    Text("Lobby")
                                        .tracking(-0.1)
                                        .font(.custom("CircularSpUIv3T-Bold", size: 12))
                                        .foregroundColor(Color.black)
                                        .padding(.leading, -3)
                                
                            }
                            .padding(7.3)
                            .padding(.leading, 7)
                            .padding(.trailing, 7)
                            .background(Color.white)
                            .cornerRadius(7)
                            .fixedSize(horizontal: true, vertical: false)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.40), lineWidth: isTapped ? 15 : 4)
                                    .rotationEffect(.degrees(0), anchor: .center)
                                
                            )
                            .onTapGesture{
                                isTapped.toggle()
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    navigationStore.push(to: .lobbyView)
                                    isTapped.toggle()
                                }
                            }
                            .padding(.top, 0)
                            
                        }
                        .padding(.trailing, 10)
                        
                    }
                VStack{
                    Button(action: {
                        // Start a party action
                    }) {
                        HStack {
                            Image(systemName:"clipboard.fill")
                                .resizable()
                                .foregroundColor(Color(red: 175/255, green: 205/255, blue: 208/255))
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                            Text("Copy party code")
                                .font(.custom("CircularSpUIv3T-Bold", size: 12))
                                .foregroundColor(Color.black)
                                .padding(.leading, -3)
                        }
                        .padding(10)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .background(Color.white)
                        .cornerRadius(7)
                        .fixedSize(horizontal: true, vertical: false)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color(uiColor: hexStringToUIColor(hex: "FFFFFF")).opacity(0.40), lineWidth: isTapped2 ? 15 : 4)
                                .rotationEffect(.degrees(0), anchor: .center)
                            
                        )
                        .onTapGesture {
                            UIPasteboard.general.string = AppState.partySession
                            isTapped2.toggle()
                            
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isActive.toggle()
                                isTapped2.toggle()
                            }
                            
                        }
                        .padding(.top, -1)
                        
                        // Ensure the button does not break
                    }
                    .padding(.trailing, 1)
                    
                    
                }
                
            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                    
            }.padding(15)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .background(
                ZStack{
                    Image("motif2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150, alignment: .leading).padding(.leading, -250)
                        .zIndex(2)
                        .rotationEffect(.degrees(5), anchor: .center)
                        .opacity(0.2)
            }
            )
            .background(Color(red: 175/255, green: 205/255, blue: 208/255))
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(uiColor: hexStringToUIColor(hex: "444E50")), lineWidth: 10)
                
            )
            .cornerRadius(15)
            
        }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .onAppear {                
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
                            print("newwwUsers")
                            print(newUsers)
                            AppState.roomUsers = newUsers
                        }
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: .roomUsersUpdated, object: nil)
            }
            .systemNotification(isActive: $isActive) {
                SystemNotificationContent2()
            }
    }
}





#Preview {
    PartyBox()
        .environmentObject(NavigationStore())
        .environmentObject(Game())
        .environmentObject(SocketHandler())
}
