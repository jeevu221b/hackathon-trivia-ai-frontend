import SocketIO
import Foundation

class SocketHandler: ObservableObject {
    let manager: SocketManager
    var socket: SocketIOClient
    
    init() {
        var token = ""
        if let user = DataManager.shared.getUser() {
            token = user.token ?? ""
            print(token)
        }
        
        let socketURL = URL(string: "ws://0.tcp.in.ngrok.io:17101")!
        let config: SocketIOClientConfiguration = [
            .log(true),
            .compress,
            .extraHeaders(["Authorization": "\(token)"])
        ]
        
        manager = SocketManager(socketURL: socketURL, config: config)
        socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
        }
        
        socket.on(clientEvent: .error) { data, ack in
            if let error = data[0] as? String {
                print("Socket error: \(error)")
            }
        }
        
        socket.connect()
    }
    
    func updatePartyData(name: String, id: String, value: String, sessionId: String) {
        let data: [String: String] = [
            "name": name, // "favorite genre"
            "id": id, // category
            "value": value, // "efewfewf"
            "sessionId": "sessionId"
        ]
        socket.emit("updatePartyData", data)
    }
    
    func leaveRoom(sessionId: String) {
        let data: [String: String] = [
            "sessionId": "sessionId"
        ]
        socket.emit("leaveRoom", data)
    }
    
    func startGame(sessionId: String) {
        let data: [String: String] = [
            "sessionId": "sessionId"
        ]
        socket.emit("gameStarted", data)
    }
    
    func isReadyNow(sessionId: String) {
        let data: [String: String] = [
            "sessionId": "sessionId"
        ]
        socket.emit("isReadyNow", data)
    }
    
    
}
