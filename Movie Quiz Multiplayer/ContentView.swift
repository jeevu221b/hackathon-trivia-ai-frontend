import SwiftUI
import Firebase
import SwiftfulFirebaseAuth
import UIKit




struct ContentView: View {
    @StateObject private var navigationStore = NavigationStore()
    @StateObject private var AppState = Game()


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
                        }
                }
                .swipeGesture(navigationStore: navigationStore, AppState: AppState)
            } else {
                ScreenOne()
                    .environmentObject(navigationStore)
                    .environmentObject(AppState)
            }
        }.environmentObject(AppState)
         .onAppear {
                AppState.checkLoggedInUser()
            }
    }
}

struct SwipeGesture: ViewModifier {
    @ObservedObject var navigationStore: NavigationStore
    @ObservedObject var AppState: Game
    @State private var showBackAlert = false

    
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
                                    } else{
                                        print("subcat")
                                        print(AppState.currentSubCategory)
                                        navigationStore.popAllScreen6()
                                        navigationStore.pop()
                                        navigationStore.push(to: .screen5(AppState.currentSubCategory))
                                        return
                                    }
                                }
                            }
                            navigationStore.pop()
                            print("Swiped back")
                        }
                    }
            )
            .alert(isPresented: $showBackAlert) {
                Alert(
                    title: Text("Warning"),
                    message: Text("You will lose your progress"),
                    primaryButton: .default(Text("Stay"), action: {
                        showBackAlert = false
                    }),
                    secondaryButton: .destructive(Text("Go Back"), action: {
                        AppState.isPlaying = false
                        navigationStore.popAllScreen6()
                        navigationStore.pop()
                        navigationStore.push(to: .screen5(AppState.currentSubCategory))
                    })
                )
            }
    }
}

extension View {
    func swipeGesture(navigationStore: NavigationStore,  AppState: Game) -> some View {
        modifier(SwipeGesture(navigationStore: navigationStore,  AppState: AppState))
    }
}


#Preview {
    ContentView()
        .statusBar(hidden: true)
}

