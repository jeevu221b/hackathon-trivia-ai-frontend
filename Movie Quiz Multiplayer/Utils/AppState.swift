import SwiftUI

struct User: Identifiable, Encodable, Decodable {
    var id: String?
    let email: String?
    let isAnonymous: Bool?
    let displayName: String
    var username: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let photoURL: URL?
    let creationDate: Date?
    let lastSignInDate: Date?
    var token: String?
}


struct Party: Identifiable, Encodable, Decodable {
    let id: String?
    var users: [Users]?
    let category: String?
    let subCategory: String?
    let level: String?
    let rounds: Int?
}

struct Users: Identifiable, Encodable, Decodable{
    var id: String
    let username: String
    let score: Int
    let lastRoundScore: Int
    let rank: Int
    let isOnline: Bool
    let photoURL: String?
    let isHost: Bool
}


// Our observable object class
class Game: ObservableObject {
    @Published var isPlaying = false
    @Published var currentSubCategory = ""
    @Published var isLoggedIn = false
    @Published var inParty = false
    @Published var partySession = ""
    @Published var isHost = false
    @Published var user: User?
    @Published var party: Party?
    @Published var isMultiplayer: Bool {
        didSet {
            UserDefaults.standard.set(isMultiplayer, forKey: "isMultiplayer")
            Task{
                try await DataManager.shared.fetchData(isMultiplayer: isMultiplayer)
            }
        }
    }
    
    init() {
        self.isMultiplayer = UserDefaults.standard.bool(forKey: "isMultiplayer")
    }
    
    func checkLoggedInUser() {
        if let userData = UserDefaults.standard.data(forKey: "loggedInUser") {
            let decoder = JSONDecoder()
            if let decodedUser = try? decoder.decode(User.self, from: userData) {
                user = decodedUser
                isLoggedIn = true
            }
        }
    }
    
    func generateMockUser() {
            let mockUser = User(
                id: "e3zzjng6mFacV4LMXsffVBOk3Or1",
                email: "santosh@transak.com",
                isAnonymous: false,
                displayName: "Santosh Pant",
                username: "blueUser007",
                firstName: "blue",
                lastName: nil,
                phoneNumber: nil,
                photoURL: URL(string: "https://lh3.googleusercontent.com/a/ACg8ocJxG6EmZgSX5ZfwLnLXLOp4vLYf--DvzierxRghgt_ZMdYghxk=s96-c"),
                creationDate: ISO8601DateFormatter().date(from: "2024-12-13T15:25:12+0000"),
                lastSignInDate: ISO8601DateFormatter().date(from: "2024-12-14T17:25:54+0000")
            )
            
            let encoder = JSONEncoder()
            if let encodedUser = try? encoder.encode(mockUser) {
                UserDefaults.standard.set(encodedUser, forKey: "loggedInUser")
                user = mockUser
                isLoggedIn = true
            }
        }
    
}


extension DataManager {
    func getUser() -> User? {
        guard let data = userDefaults.data(forKey: "loggedInUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    func saveUser(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        userDefaults.set(data, forKey: "loggedInUser")
    }
}
