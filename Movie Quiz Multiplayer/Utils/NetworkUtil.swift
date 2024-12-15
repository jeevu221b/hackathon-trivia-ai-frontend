import Foundation
let baseUrl = "http://15.206.111.44:5000"
var baseS3 = "https://elasticbeanstalk-ap-south-1-905418193722.s3.ap-south-1.amazonaws.com/trivia/"

struct APIResponse: Codable {
    let categories: [Category]
    let subcategories: [Subcategory]
    let levels: [Level]
}

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let image: String?
    let subtext: String?
    let isBanner: Bool
    let displayName: String?
}

struct Subcategory: Codable {
    let id: String
    let category: String
    let name: String
    let image: String
    let facts: [String]?
}

struct Level: Codable, Identifiable {
    let id: String
    let level: Int
    let isUnlocked: Bool
    let isCompleted: Bool?
    let star: Int?
    let score: Int?
    let subCategory: String
    let image: String?
}


struct APIInfo: Identifiable {
    let id = UUID()
    let endpointName: String
    let endpointURL: URL
}

struct Question: Codable {
    let question: String
    let options: [String]
    let answer: Int
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case question, options, answer
        case id = "_id"
    }
}



let getAllDataAPIInfo: APIInfo = APIInfo(
    endpointName: "getAllData",
    endpointURL: URL(string: "\(baseUrl)/api/data")!
)

func getAllData() async throws -> Data {
    let url = getAllDataAPIInfo.endpointURL
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Add the token to the Authorization header
    if let user = DataManager.shared.getUser() {
        request.setValue("\(user.token ?? "")", forHTTPHeaderField: "Authorization")
    }
    
    let (data, response) = try await URLSession.shared.data(for: request)
    print(data)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    return data
}

class DataManager {
    static let shared = DataManager()
    
    public let userDefaults = UserDefaults.standard
    
    private init() {}
    
    
    func fetchData() async throws {
        let data = try await getAllData()
        
        // Decode the received data
        let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
        
        // Store the decoded data in UserDefaults
//        print(apiResponse.categories)
        saveCategories(apiResponse.categories)
        saveSubcategories(apiResponse.subcategories)
        saveLevels(apiResponse.levels)
    }
    
    func getCategories() -> [Category] {
        guard let data = userDefaults.data(forKey: "categories"),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return []
        }
        return categories
    }
    
    func getSubcategoriesForCategory(categoryId: String) -> [Subcategory] {
        let subcategories = DataManager.shared.getSubcategories()
        return subcategories.filter { $0.category == categoryId }
    }
    
    func getSubcategories() -> [Subcategory] {
        guard let data = userDefaults.data(forKey: "subcategories"),
              let subcategories = try? JSONDecoder().decode([Subcategory].self, from: data) else {
            return []
        }
        return subcategories
    }
    
    func getLevels() -> [Level] {
        guard let data = userDefaults.data(forKey: "levels"),
              let levels = try? JSONDecoder().decode([Level].self, from: data) else {
            return []
        }
        return levels
    }
    
    private func saveCategories(_ categories: [Category]) {
        guard let data = try? JSONEncoder().encode(categories) else { return }
        userDefaults.set(data, forKey: "categories")
    }
    
    private func saveSubcategories(_ subcategories: [Subcategory]) {
        guard let data = try? JSONEncoder().encode(subcategories) else { return }
        userDefaults.set(data, forKey: "subcategories")
    }
    
    func saveLevels(_ levels: [Level]) {
        guard let data = try? JSONEncoder().encode(levels) else { return }
        userDefaults.set(data, forKey: "levels")
    }
}


struct GetQuestionsAPIInfo: Identifiable {
    let id = UUID()
    let endpointName: String
    let endpointURL: URL
}

let getQuestionsAPIInfo: GetQuestionsAPIInfo = GetQuestionsAPIInfo(
    endpointName: "getQuestions",
    endpointURL: URL(string: "\(baseUrl)/api/get/question")!
)

func getQuestions(levelId: String) async throws -> [Question] {
    print("get questions")
    let url = getQuestionsAPIInfo.endpointURL
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Add the token to the Authorization header
    if let user = DataManager.shared.getUser() {
        request.setValue("\(user.token ?? "")", forHTTPHeaderField: "Authorization")
    }
    
    let requestBody = ["levelId": levelId]
    request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.badServerResponse)
    }
    
    let decoder = JSONDecoder()
    let questions = try decoder.decode([Question].self, from: data)
    return questions
}

func createSession(levelId: String, multiplayer: Bool) async -> String? {
    let url = URL(string: "\(baseUrl)/api/create/session")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Add the token to the Authorization header
    if let user = DataManager.shared.getUser() {
        request.setValue("\(user.token ?? "")", forHTTPHeaderField: "Authorization")
    }
    
    let body: [String: Any] = [
        "levelId": levelId,
        "multiplayer": multiplayer
    ]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let id = json["sessionId"] as? String {
            print("sessionId created")
            print(id)
            return id
         } else {
             print("Failed to parse session response")
             return nil
         }
     } catch {
         print("Error creating session: \(error)")
         return nil
     }
}


func updateLevels(with levelsToUpdate: [Level]) {
    var updatedLevels = DataManager.shared.getLevels()
    
    for levelToUpdate in levelsToUpdate {
        if let index = updatedLevels.firstIndex(where: { $0.id == levelToUpdate.id }) {
            updatedLevels[index] = levelToUpdate
        }
    }
    
    // Save the updated levels to local storage
    DataManager.shared.saveLevels(updatedLevels)
    
}


func loginUser(email: String) async {
    let url = URL(string: "\(baseUrl)/api/login")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: String] = ["email": email]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let token = json["token"] as? String {
            // Update the user object with the token
            if var user = DataManager.shared.getUser() {
                user.token = token
                DataManager.shared.saveUser(user)
                print("Token saved successfully")
            } else {
                print("User not found")
            }
        } else {
            print("Failed to parse login response")
        }
    } catch {
        print("Error logging in: \(error)")
    }
}
