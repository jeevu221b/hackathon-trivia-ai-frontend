import SwiftUI

struct User: Identifiable, Encodable, Decodable {
    let id: String?
    let email: String?
    let isAnonymous: Bool?
    let displayName: String
    let firstName: String?
    let lastName: String?
    let phoneNumber: String?
    let photoURL: URL?
    let creationDate: Date?
    let lastSignInDate: Date?
}

// Our observable object class
class Game: ObservableObject {
    @Published var isPlaying = false
    @Published var currentSubCategory = ""
    @Published var isLoggedIn = false
    @Published var user: User?
    
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
                firstName: nil,
                lastName: nil,
                phoneNumber: nil,
                photoURL: URL(string: "https://lh3.googleusercontent.com/a/ACg8ocJxG6EmZgSX5ZfwLnLXLOp4vLYf--DvzierxRghgt_ZMdYghxk=s96-c"),
                creationDate: ISO8601DateFormatter().date(from: "2024-12-9T15:25:12+0000"),
                lastSignInDate: ISO8601DateFormatter().date(from: "2024-12-10T17:25:54+0000")
            )
            
            let encoder = JSONEncoder()
            if let encodedUser = try? encoder.encode(mockUser) {
                UserDefaults.standard.set(encodedUser, forKey: "loggedInUser")
                user = mockUser
                isLoggedIn = true
            }
        }
    
}
