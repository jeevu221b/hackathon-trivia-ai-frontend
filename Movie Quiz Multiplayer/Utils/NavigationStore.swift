import SwiftUI
enum NavigationDestination: Hashable {
    case screen1(Bool), screen2, screen3, screen4(String), screen5(String), screen6(String), leaderBoardPage
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .screen1(let logout):
            ScreenOne(logout: logout)
        case .screen2:
            ScreenTwo()
        case .screen3:
            ScreenThree()
        case .screen4(let catId):
            ScreenFour(catId: catId)
        case .screen5(let subcategoryId):
            ScreenFive(subcategoryId: subcategoryId)
        case .screen6(let levelId):
            ScreenSix(levelId: levelId)
        case .leaderBoardPage:
            LeaderboardView()
        }
    }
}

final class NavigationStore: ObservableObject {
    @Published var path: [NavigationDestination] = []
    
    func push(to view: NavigationDestination) {
        path.append(view)
    }
    
    func pop() {
        if path.count > 1 {
            path.removeLast()
        }
    }
    
    func popAllScreen6() {
          path.removeAll { destination in
              if case .screen6 = destination {
                  return true
              }
              return false
          }
      }
    
    func popToRoot() {
            path.removeAll()
        }
}
