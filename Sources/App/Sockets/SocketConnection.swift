//
//  SocketConnection.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-15.
//

import Vapor
import Fluent

class SocketConnection<RoomID: Hashable, ConnectionID: Hashable>: SocketHandler, Hashable {
    
    typealias Room = SocketRoom<RoomID, ConnectionID>
    
    let id: ConnectionID
    let ws: WebSocket
    let conn: DatabaseConnectable
    
    weak var room: Room? 
    
    private let uniqueKey: UInt32
    
    var hashValue: Int {
        return id.hashValue + uniqueKey.hashValue
    }
    
    init(id: ConnectionID, ws: WebSocket, conn: DatabaseConnectable) {
        self.id = id
        self.uniqueKey = arc4random_uniform(1000)
        self.ws = ws
        self.conn = conn
    }
    
    func onConnection() {
        ws.onBinary(self.onBinary)
        ws.onText(self.onText)
        ws.onError(self.onError)
        ws.onCloseCode(self.onCloseCode)
        ws.onClose.always(self.onDisconnection)
    }
    
    func onBinary(_ ws: WebSocket, _ data: Data) {
        room?.onBinary(data, from: self)
    }
    
    func onText(_ ws: WebSocket, _ text: String) {
        room?.onText(text, from: self)
    }
    
    func onError(_ ws: WebSocket, _ error: Error) {
        print("WebScket Got Error: ", error)
        ws.close(code: .unexpectedServerError)
    }
    
    func onCloseCode(_ code: WebSocketErrorCode) {
        print("WebSocket Close Code: ", code)
    }
    
    func onDisconnection() {
        print("WebSocket Disconnected")
        room?.disconnect(self)
    }
    
    static func == (lhs: SocketConnection<RoomID, ConnectionID>, rhs: SocketConnection<RoomID, ConnectionID>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
}
