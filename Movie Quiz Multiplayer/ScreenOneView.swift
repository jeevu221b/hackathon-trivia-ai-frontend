import SwiftUI
import SwiftfulFirebaseAuth
import Firebase


struct ScreenOne: View {
    var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    var logout:  Bool? = false
    @EnvironmentObject private var navigationStore : NavigationStore
    public let authManager = AuthManager(configuration: .firebase)
    @EnvironmentObject var AppState: Game
    
    init(logout: Bool? = nil){
        self.logout = logout
        if logout == true {
            do {
                try authManager.signOut()
                UserDefaults.standard.removeObject(forKey: "loggedInUser")
            } catch {
                print("Error signing out: \(error)")
            }
        }
    }
     
    let clientId = FirebaseApp.app()?.options.clientID
    @State var appleLogin = false
    
    var body: some View {
        ZStack {
            Image("screen1")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            LinearGradient(
                colors: [Color.black.opacity(0) ,Color.black.opacity(0.1),  Color.black.opacity(1)],
                startPoint: .topLeading,
                endPoint: .bottomLeading
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                VStack(alignment: .leading, spacing:0) {
                    Text("BlockbuspopToRootter")
                    Text("Brainteaser Bonanza!").padding(.top, -7)
                }
                .font(Font.custom("CircularSpUIv3T-Bold", size: 33))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 40)
                
                Text("Test your Hollywood knowledge in our thrilling quiz game.\nLights, camera, action, trivia!")
                    .font(Font.custom("CircularSpUIv3T-Book", size: 12))
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "ABABAB")))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40)
                    .padding([.bottom], 12)
                    .padding([.top], 3)
                
                Button(action: {
                    loginAction()
                }) {
                    if !AppState.isLoggedIn && !appleLogin {
                        HStack{
                            Image("g")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14)
                            Text("Login with Google")
                                .font(Font.custom("CircularSpUIv3T-Bold", size: 15))
                        }
                                .frame(width: 285, height: 37)
                                .padding(15)
                        
                    } else {
                        ThreeBounceAnimation(color: .white, width: CGFloat(15), height: CGFloat(15))
                            .frame(width: 285, height: 37)
                            .padding(15)
                    }
                }
                .foregroundColor(.white)
                .background(Color(uiColor: hexStringToUIColor(hex: "80C64A")).opacity(0.85))
                .cornerRadius(10)
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity,  alignment: .leading)
                .padding(.leading, 40)
                .padding(.bottom, 30)
                .scaleEffect(appleLogin ? 1.04 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: appleLogin)
            }
        }
    }
    
    private func loginAction() {
        if appleLogin {
            return
        }
        
        Task {
            do {
                appleLogin = true
                if isPreview {
                    AppState.generateMockUser()
                    if let email = AppState.user?.email {
                        await loginUser(email: email)
                    }
                    navigationStore.push(to: .screen2)
                    return
                }
                
                if let clientId = clientId, !clientId.isEmpty {
                    let (user, _) = try await authManager.signInGoogle(GIDClientID: clientId)
                    AppState.user = User(id: user.uid,
                                         email: user.email ?? "",
                                         isAnonymous: user.isAnonymous,
                                         displayName: user.displayName ?? "",
                                         firstName: user.firstName,
                                         lastName: user.lastName,
                                         phoneNumber: user.phoneNumber,
                                         photoURL: user.photoURL,
                                         creationDate: user.creationDate ?? Date(),
                                         lastSignInDate: user.lastSignInDate ?? Date())
                    
                    let encoder = JSONEncoder()
                    if let encodedUser = try? encoder.encode(AppState.user) {
                        UserDefaults.standard.set(encodedUser, forKey: "loggedInUser")
                    }
                    
                    // Call the loginUser function with the user's email
                    if let email = user.email {
                        await loginUser(email: email)
                    }
                    
                    AppState.isLoggedIn = true
                    navigationStore.popToRoot()
                    navigationStore.push(to: .screen2)
                }
            } catch {
                print(error)
            }
            appleLogin = false
        }
    }
}


#Preview {
    ScreenOne()
        .environmentObject(NavigationStore())
        .environmentObject(Game())
}
