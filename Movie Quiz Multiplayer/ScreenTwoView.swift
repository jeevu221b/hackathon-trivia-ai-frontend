
import SwiftUI

struct ScreenTwo: View {
    @EnvironmentObject private var navigationStore : NavigationStore
    @State private var errorMessage: String = ""
    @State private var loading: Bool = false
    @State private var loader: Bool = true

    init(){
        print("INIT SCREEN 2")
    }
    let font = UIFont(name: "CircularSpUIv3T-Bold", size: 10)!
    @State var appleLogin = false
    @Namespace var namespace
    var body: some View {
            VStack {
                if loader {
                    LoaderFullScreen(text:"Loading")
                } else {
                    ZStack {
                        Image("Screen2")
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(CGSize(width: 10, height: 10), contentMode: .fill)
                            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        
                        LinearGradient(
                            colors: [Color.black.opacity(0) ,Color.black.opacity(0.1),  Color.black.opacity(1)],
                            startPoint: .topLeading,
                            endPoint: .bottomLeading
                        )
                        .edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 0) {
                            Menu()
                                .padding(.trailing, 15)
                                .padding(.top, -10)
                            Spacer()
                            VStack(alignment: .leading, spacing:0) {
                                Text("Reel Knowledge,")
                                Text("Real Fun!").padding(.top, -7)
                            }
                            .font(Font.custom("CircularSpUIv3T-Bold", size: 33))
                            .foregroundColor(.white)
                            //                    .frame(width: 320, height: 200)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 40)
                            //                    .border(Color.red)
                            
                            Text("Test your Hollywood knowledge in our thrilling quiz game.\nLights, camera, action, trivia!")
                                .font(Font.custom("CircularSpUIv3T-Book", size: 12))
                                .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "ABABAB")))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 40)
                                .padding([.bottom], 12)
                                .padding([.top], 3)
                            
                            
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    appleLogin.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                    appleLogin.toggle()
                                    navigationStore.push(to: .screen3)
                                }
                            }) {
                                if !loading {
                                    HStack {
                                        
                                        Text(errorMessage.isEmpty ? "PLAY" : "Error :(")
                                            .font(Font.custom("CircularSpUIv3T-Bold", size: 15))
                                        //                               .frame(width: 300)
                                        
                                    }
                                    .frame(width: 285, height: 37)
                                    .padding(15)
                                } else {
                                    HStack {
                                        ThreeBounceAnimation(color: .white, width: CGFloat(15), height: CGFloat(15))
                                        
                                        
                                    }
                                    .frame(width: 285, height: 37)
                                    .padding(15)
                                    
                                    
                                }
                                
                            }
                            
                            .opacity(0.9)
                            .foregroundColor(.white)
                            .background(Color(uiColor: hexStringToUIColor(hex: "D39E8B")))
                            .cornerRadius(10)
                            .buttonStyle(.plain)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,  alignment: .leading)
                            .padding(.leading, 40)
                            .padding(.bottom, 15)
                            .scaleEffect(appleLogin ? 1.04 : 1)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6))
                            .onTapGesture {
                                if errorMessage.isEmpty {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                        navigationStore.push(to: .screen3)
                                    }
                                } else{
                                    Task{
                                        await fetchData()
                                    }
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                }
            }.onAppear {
                Task {
                    await fetchData()
//                    print("adata")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        loader.toggle()
                    }
                }
                
              
            }
            .navigationBarBackButtonHidden(true)
            
            

        }
    
    
    func fetchData() async {
        do {
            loading = true
            try await DataManager.shared.fetchData()
            loading = false
            errorMessage = ""
        } catch {
            loading = false
            // Handle any errors that occurred
            print("Error: \(error)")
            errorMessage = "Error occurred while fetching data"
            
        }
    }

}


#Preview {
    ScreenTwo()
        .environmentObject(Game())
        .statusBar(hidden: true)
}

