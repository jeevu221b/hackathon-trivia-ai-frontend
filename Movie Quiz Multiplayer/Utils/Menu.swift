import SwiftUI

struct Menu: View {
    @EnvironmentObject var AppState: Game
    @EnvironmentObject private var navigationStore: NavigationStore
    @State private var isTapped = false
    
    var body: some View {
        VStack {
            imageView
                .frame(width: 45, height: 45)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: isTapped ? 10 : 0)
                )
                .scaleEffect(isTapped ? 1.2 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTapped.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        isTapped.toggle()
                        navigationStore.push(to: .profile)
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 15)
        .padding(.top, -20)
    }
    
    @ViewBuilder
    private var imageView: some View {
        if AppState.isLoggedIn {
            if let photoURL = AppState.user?.photoURL {
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image("user")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        } else {
            Image("user")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
}
