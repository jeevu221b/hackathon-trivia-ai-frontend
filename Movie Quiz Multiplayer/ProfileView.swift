import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var AppState: Game
    @State private var showLogOutAlert = false
    @State private var username = ""
    @State private var score = 0
    @State private var stars = 0
    @State private var rank = 0
    private let darkBackgroundColor = Color(red: 23/255, green: 24/255, blue: 25/255)
    private let green = Color(uiColor: hexStringToUIColor(hex: "137662"))
    private let _gery = Color(uiColor: hexStringToUIColor(hex: "272729"))

    var body: some View {
        ZStack {
            darkBackgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer().frame(height: 30)
                
                profileSection
                
                Spacer().frame(height: 40)
                
                optionsSection
                
                Spacer()
                
                logoutButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showLogOutAlert) {
            logoutAlert
        }
        .onAppear {
            AppState.checkLoggedInUser()
            fetchProfileData()
        }
    }

    @ViewBuilder
    private var profileSection: some View {
        VStack {
            if let photoURL = AppState.user?.photoURL {
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            } else {
                Image("user")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Text(AppState.user?.displayName ?? "No Name")
                .font(Font.custom("CircularSpUIv3T-Bold", size: 35))
                .foregroundColor(Color.white)
            
            Text("@\(username)")
                .font(Font.custom("CircularSpUIv3T-Book", size: 19))
                .foregroundColor(Color.white.opacity(0.5))
                .padding(.bottom, 15)
            
            HStack(spacing: 5) {
                Image("filledstar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    
                Text("\(stars)")
                    .font(Font.custom("CircularSpUIv3T-Bold", size: 25))
                    .foregroundColor(Color(uiColor: hexStringToUIColor(hex: "FFDA40")))
            }
            .padding(.top, -10)
            
            HStack(spacing: 40) {
                statItem(value: score, label: "Score")
                statItem(value: rank, label: "Rank")
                statItem(value: 0, label: "Rewards")
            }
            .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    private func statItem(value: Int, label: String) -> some View {
        VStack {
            Text("\(value)")
                .font(Font.custom("CircularSpUIv3T-Bold",size:20))
                .foregroundColor(Color.white)
            Text(label)
                .font(Font.custom("CircularSpUIv3T-Book",size:15))
                .foregroundColor(Color.gray)
        }
    }

    @ViewBuilder
    private var optionsSection: some View {
        VStack(spacing: 0) {
            OptionRow(icon: "bell.badge.fill", text: "Notifications", hasToggle: true)
            OptionRow(icon: "person.2.fill", text: "Enable multiplayer mode", hasToggle: true)
            OptionRow(icon: "speaker.wave.1.fill", text: "Enable sounds", hasToggle: true)
        }
        .background(_gery)
        .cornerRadius(15)
        .padding(25)
        .padding(.bottom, 25)
    }

    private var logoutButton: some View {
        Button(action: {
            showLogOutAlert = true
        }) {
            Text("Log out")
                .font(Font.custom("CircularSpUIv3T-Book", size: 20))
                .foregroundColor(.white.opacity(0.7))
                .padding(22)
                .frame(maxWidth: .infinity)
                .background(_gery)
                .cornerRadius(15)
                .padding(.horizontal, 20)
        }
        .padding(10)
        .padding(.bottom, 0)
    }

    private var logoutAlert: Alert {
        Alert(
            title: Text("Warning"),
            message: Text("You will be logged out"),
            primaryButton: .default(Text("Log out"), action: {
                AppState.isLoggedIn = false
                AppState.user = nil
                UserDefaults.standard.removeObject(forKey: "loggedInUser")
                // Handle any additional logout actions
            }),
            secondaryButton: .destructive(Text("Cancel"), action: {
                showLogOutAlert = false
            })
        )
    }

    private func fetchProfileData() {
        guard let url = URL(string: "\(baseUrl)/api/get/profile") else {
            return
        }
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let user = DataManager.shared.getUser() {
            print(user.token)
            request.setValue("\(user.token ?? "")", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.username = json["username"] as? String ?? ""
                        self.score = json["score"] as? Int ?? 0
                        self.stars = json["stars"] as? Int ?? 0
                        self.rank = json["rank"] as? Int ?? 0
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct OptionRow: View {
    var icon: String
    var text: String
    var hasToggle: Bool = false
    @State private var isToggled = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 20))
                .frame(width: 35, alignment: .center)

            Text(text)
                .font(Font.custom("CircularSpUIv3T-Book", size: 17))
                .foregroundColor(Color.white)
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: $isToggled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .green))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
        }
        .padding()
    }
}

#Preview {
    UserProfileView()
        .statusBar(hidden: true)
        .environmentObject(Game()) 
}

