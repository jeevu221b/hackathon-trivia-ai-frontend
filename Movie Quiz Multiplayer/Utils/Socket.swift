import SocketIO
import Foundation
import Network
import NotificationCenter


class SocketHandler: ObservableObject {
    let manager: SocketManager
    var socket: SocketIOClient
    var monitor: NWPathMonitor
    let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnected: Bool = true
    
    init() {
        var token = ""
        if let user = DataManager.shared.getUser() {
            token = user.token ?? ""
            print(token)
        }
        
        let socketURL = URL(string: "ws://15.206.111.44:4001")!
        let config: SocketIOClientConfiguration = [
            .log(true),
            .compress,
            .reconnects(true),
            .reconnectAttempts(-1),
            .reconnectWaitMax(3),
            .reconnectWait(2),
            .forcePolling(true),
            .extraHeaders(["Authorization": "\(token)"])
        ]
        
        manager = SocketManager(socketURL: socketURL, config: config)
        socket = manager.defaultSocket
        monitor = NWPathMonitor()
        
        // Define socket event handlers
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            print("Socket connected")
            DispatchQueue.main.async {
                self?.isConnected = true
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("Socket disconnected")
            DispatchQueue.main.async {
                self?.isConnected = false
                self?.showDisconnectAlert()
            }
        }
        
        socket.on(clientEvent: .statusChange) { data, ack in
            print("Socket status change: \(data)")
        }
        
        socket.on(clientEvent: .error) { [weak self] data, ack in
            if let error = data[0] as? String {
                print("Socket error: \(error)")
            }
            DispatchQueue.main.async {
                self?.isConnected = false
                self?.showDisconnectAlert()
            }
        }
        
        socket.on("roomUsers") { [weak self] data, ack in
              print(data)
              NotificationCenter.default.post(name: .roomUsersUpdated, object: data)
          }
        
        
        // Start monitoring network connectivity
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                print("Internet connection available")
                if self?.socket.status != .connected {
                    self?.socket.connect()
                }
            } else {
                print("No internet connection")
                DispatchQueue.main.async {
                    self?.isConnected = false
                    self?.showDisconnectAlert()
                }
            }
        }
        monitor.start(queue: queue)
        
        // Connect the socket
        socket.connect()
    }
    
    func showDisconnectAlert() {
        // Show your alert here, for example using an AlertController in a SwiftUI or UIKit context
        //send socketDisconnected event in UI for other swiftUI files
        NotificationCenter.default.post(name: .socketDisconnected, object: nil)

        print("Internet connection lost. Please check your connection.")
    }
    
    func updatePartyData(name: String, id: String, value: String, sessionId: String) {
        let data: [String: String] = [
            "name": name,
            "id": id,
            "value": value,
            "sessionId": sessionId
        ]
        socket.emit("updatePartyData", data)
    }
    
    func leaveRoom(sessionId: String) {
        let data: [String: String] = [
            "sessionId": sessionId
        ]
        socket.emit("leaveRoom", data)
    }
    
    func startGame(sessionId: String) {
        let data: [String: String] = [
            "sessionId": sessionId
        ]
        socket.emit("gameStarted", data)
    }
    
    func isReadyNow(sessionId: String) {
        let data: [String: String] = [
            "sessionId": sessionId
        ]
        socket.emit("isReadyNow", data)
    }

    
    func onAnswer(sessionId: String, index: Int, answer: Bool) {
        let data: [String: Any] = [
            "sessionId": sessionId,
            "index": index,
            "answer": answer
        ]
        socket.emit("onAnswer", data)
    }
}



extension Notification.Name {
    static let socketDisconnected = Notification.Name("socketDisconnected")
    static let roomUsersUpdated = Notification.Name("roomUsersUpdated")

}
