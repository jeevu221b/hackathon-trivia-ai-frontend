import SwiftUI
import Firebase
import SwiftfulFirebaseAuth
import UIKit
struct ContentView: View {
    @StateObject private var navigationStore = NavigationStore()
    @StateObject private var AppState = Game()
    @StateObject private var socketHandler = SocketHandler()

    init() {
        FirebaseApp.configure()
    }
    var body: some View {
        NavigationView {
            if AppState.isLoggedIn {
                NavigationStack(path: $navigationStore.path) {
                    ScreenTwo()
                        .environmentObject(navigationStore)
                        .environmentObject(AppState)
                        .navigationDestination(for: NavigationDestination.self) { path in
                            path.view
                                .environmentObject(navigationStore)
                                .environmentObject(AppState)
                                .environmentObject(socketHandler)
                        }
                }
                .swipeGesture(navigationStore: navigationStore, AppState: AppState)
            } else {
                ScreenOne()
                    .environmentObject(navigationStore)
                    .environmentObject(AppState)
                    .environmentObject(socketHandler)
            }
        }.environmentObject(AppState)
            .environmentObject(socketHandler)
         .onAppear {
                AppState.checkLoggedInUser()
            }
    }
}

struct SwipeGesture: ViewModifier {
    @ObservedObject var navigationStore: NavigationStore
    @ObservedObject var AppState: Game
    @State private var showBackAlert = false
    @StateObject private var socketHandler = SocketHandler()

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 50 && navigationStore.path.count > 1 {
                            if let lastView = navigationStore.path.last {
                                if case .screen6 = lastView {
                                    if AppState.isPlaying {
                                        showBackAlert = true
                                        return
                                    } else {
                                        print("going back")
                                        navigationStore.popAllScreen6()
                                        navigationStore.pop()
                                        navigationStore.push(to: .screen5(AppState.currentSubCategory))
                                        return
                                    }
                                } else if case .lobbyView = lastView {
                                    //if not admin don't allow to go back
                                    print(AppState.isHost)
                                    if AppState.isHost {
                                        navigationStore.pop()
                                        return
                                    }
                                    return
                                } else if case .screen7 = lastView {
                                    //leave party
                                    showBackAlert = true
                                    return
                                }
                            }
                            navigationStore.pop()
                            print("Swiped back")
                        }
                    }
            )
            .backAlert(
                showBackAlert: $showBackAlert,
                onStay: {
                    showBackAlert = false
                },
                onGoBack: {
                    if let lastView = navigationStore.path.last {
                        if case .screen7 = lastView {
                            //Leave the party and navigate to home
                            socketHandler.leaveRoom(sessionId: AppState.partySession)
                            AppState.inParty = false
                            AppState.partySession = ""
                            navigationStore.popToRoot()
                            navigationStore.push(to: .screen3)
                        } else {
                            // Default onGoBack logic for other screens
                            AppState.isPlaying = false
                            navigationStore.popAllScreen6()
                            navigationStore.pop()
                            navigationStore.push(to: .screen5(AppState.currentSubCategory))
                        }
                    }
                },
                lastView: {
                    navigationStore.path.last
                }
            )
    }
}

extension View {
    func swipeGesture(navigationStore: NavigationStore,  AppState: Game) -> some View {
        modifier(SwipeGesture(navigationStore: navigationStore,  AppState: AppState))
    }
}

extension View {
    func backAlert(showBackAlert: Binding<Bool>, onStay: @escaping () -> Void, onGoBack: @escaping () -> Void, lastView: @escaping () -> NavigationDestination?) -> some View {
        modifier(BackAlertModifier(showBackAlert: showBackAlert, onStay: onStay, onGoBack: onGoBack, lastView: lastView))
    }
}

#Preview {
    ContentView()
        .statusBar(hidden: true)
}
