import SwiftUI

struct LeaderboardButton: View {
    var containerWidth:CGFloat = UIScreen.main.bounds.width + 20
    var body: some View {
        VStack(alignment: .center) {
                HStack {
                    VStack(alignment: .leading){
                        Text("Leaderboard")
                            .tracking(-0.5)
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 18))
                            .foregroundColor(.white)
                        
//                        Text("Secure your spot on the leaderboard for four days straight\n and snag a Weekday Pass for PVR INOX!")
                        Text("Win and Snag a Weekday Pass!")
                            .tracking(-0.5)
                            .font(Font.custom("CircularSpUIv3T-Book", size: 9))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "CEB0AE")))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(0)
                        
                        Image("pvr")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 85)
                        .padding(.top, -3)
                        .padding(.leading, -3)
                        
                        

                        
                    }.padding(.leading, 30)
                        .padding(5)
                        .padding(.top, -3)
                        .padding(.bottom, -3)
                    
                    Spacer()
                
                }
                .padding(7)
                .background(Color(uiColor: hexStringToUIColor(hex: "6F1612")))
                .cornerRadius(7)
            
                ZStack(alignment: .trailing) {
                    Image("crown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 85)
                        .padding(.top, -93)
                        .padding(.leading, 310)
                        .opacity(0.95)
                        
                    
                       
                }.frame(alignment: .trailing)
            
            
            }

        .frame(width:  containerWidth, alignment: .center)
        
    }
    }


struct LeaderboardButtonOne: View{
    var containerWidth:CGFloat = UIScreen.main.bounds.width - 32.0
    var body: some View {
        VStack(alignment: .leading) {
            Text("Leaderboard")
                .font(Font.custom("CircularSpUIv3T-Bold", size: 45))
                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "474444")))
                .padding(.leading, 7)
                .tracking(-1.85)
                .padding(.bottom, 2)
                HStack {
                    VStack(alignment: .leading){
                        
                        Text("Secure your spot on the leaderboard for four days straight and snag a PVR Weekday Pass!")
                            .tracking(-0.5)
                            .font(Font.custom("CircularSpUIv3T-Book", size: 16))
                            .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "E6DCDB")))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(0)
                        
                        Image("pvr")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 145)
                        .padding(.top, -3)
                        .padding(.leading, -5)
                        
                        

                        
                    }
                    
                    .padding(.leading, 7)
                        .padding(5)
                        .padding(.top, -3)
                        .padding(.bottom, -3)
                    
                    Spacer()
                
                }
                .padding(15)
                .padding(.trailing, 42)
                .background(Color(uiColor: hexStringToUIColor(hex: "6F1612")))
                .cornerRadius(9)
            
                ZStack(alignment: .trailing) {
                    Image("crown")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 105)
                        .padding(.top, -113)
                        .padding(.leading, 263)
                        .opacity(0.95)
                        
                    
                       
                }.frame(alignment: .trailing)
            
            
            }

        .frame(width:  containerWidth, alignment: .center)
        
    }
    }
#Preview {
    LeaderboardButtonOne()
}
