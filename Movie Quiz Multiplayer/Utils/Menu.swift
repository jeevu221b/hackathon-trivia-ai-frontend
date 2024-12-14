import SwiftUI

struct Menu: View {
    @EnvironmentObject var AppState: Game
    @EnvironmentObject private var navigationStore: NavigationStore

    @State private var showLogOutAlert = false

    var body: some View {
        VStack {
            if AppState.isLoggedIn {
                if let photoURL = AppState.user?.photoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                            .onTapGesture {
                                showLogOutAlert = true
                            }
                    } placeholder: {
                        ProgressView()
                            .onTapGesture {
                                showLogOutAlert = true
                            }

                    }
                } else {
                    Image("user")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 45, height: 45)
                        .onTapGesture {
                            showLogOutAlert = true
                        }
                }
            } else {
                Image("user")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        showLogOutAlert = true
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 15)
        .padding(.top, 5)
        .alert(isPresented: $showLogOutAlert) {
            Alert(
                title: Text("Warning"),
                message: Text("You will be logged out"),
                primaryButton: .default(Text("Log out"), action: {
                    AppState.isLoggedIn = false
                    AppState.user = nil
                    UserDefaults.standard.removeObject(forKey: "loggedInUser")
                    navigationStore.push(to: .screen1(true))
                }),
                secondaryButton: .destructive(Text("Cancel"), action: {
                    showLogOutAlert = false
                })
            )
        }
    }
}
