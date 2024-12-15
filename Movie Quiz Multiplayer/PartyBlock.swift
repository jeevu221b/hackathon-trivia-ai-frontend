import SwiftUI



struct PartyBox: View {
    @State var isTapped = false
    @EnvironmentObject var AppState: Game
    
    func changeIsTapped(){
        isTapped.toggle()
    }
    
    var body: some View {
        if AppState.inParty {
            PartyCreatedView()
        } else{
            CreatePartyView(changeIsTapped: changeIsTapped)
        }
        
    }
}
    
    
    
    
struct CreatePartyView: View {
    let changeIsTapped: () -> Void
    @State var isTapped = false
    @EnvironmentObject var AppState: Game

    
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
                                    .font(.custom("CircularSpUIv3T-Bold", size: 8))
                                    .foregroundColor(Color.black)
                                    .padding(.leading, -3)
                            }
                        }
                        .padding(2)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
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
                            var sessionId = ""
                            Task {
                                sessionId = await createSession(levelId: "", multiplayer: true) ?? ""
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                                AppState.inParty = true
                                AppState.partySession = sessionId
                                isTapped.toggle()
                            }
                           
                        }
                        .padding(.top, -5)
                        
                        // Ensure the button does not break
                    }
                    .padding(.trailing, 0)
                    
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
    }
}



struct PartyCreatedView: View {
    @State var isTapped = false
    @EnvironmentObject var AppState: Game

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
                        AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/a/ACg8ocIl0o9w9Fsj2TSM3qe70W1pOTD0VzB8-ZIxNzO1lqGctqE0NDM=s83-c-mo")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        AsyncImage(url: URL(string: "https://lh3.googleusercontent.com/ogw/AF2bZyj3cgbRS02czvO6eDGD8X9h3TO043G2vW2h79vQaEaoZQ=s32-c-mo")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        AsyncImage(url: URL(string: "https://scontent.cdninstagram.com/v/t51.2885-19/431517202_345923184456455_9054661420118065202_n.jpg?stp=dst-jpg_s100x100&_nc_cat=108&ccb=1-7&_nc_sid=3fd06f&_nc_ohc=ZhF_8lfVjdcQ7kNvgFktmxj&_nc_ad=z-m&_nc_cid=0&_nc_ht=scontent.cdninstagram.com&oh=00_AYCXJeY4LMpkNzF0HZ33vHq1SnTqvTtA6uQhG-9PKbc_iQ&oe=666018DB")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                    }

                }
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                .padding(0)
                .padding(.leading, 5)
                
                VStack {
                    Button(action: {
                        // Start a party action
                    }) {
                        HStack {
                            Image("whatsapp") // Replace with the actual image name if needed
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                            Text("Invite your friends")
                                .font(.custom("CircularSpUIv3T-Bold", size: 8))
                                .foregroundColor(Color.black)
                                .padding(.leading, -3)
                        }
                        .padding(5)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
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
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isTapped.toggle()
                            }
                           
                        }
                        .padding(.top, -17)
                        
                        // Ensure the button does not break
                    }
                    .padding(.trailing, 0)
                    
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
    }
}





#Preview {
    PartyBox()
        .environmentObject(NavigationStore())
        .environmentObject(Game())
}
