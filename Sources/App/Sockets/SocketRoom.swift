//
//  SocketRoom.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-15.
//

import Vapor
import Fluent

class SocketRoom<RoomID: Hashable, ConnectionID: Hashable>: Hashable {
    
    typealias Connection = SocketConnection<RoomID, ConnectionID>
    
    let id: RoomID
    var connections: Set<Connection>
    
    var hashValue: Int {
        return id.hashValue
    }
    
    init(id: RoomID, connection: Connection) {
        self.id = id
        self.connections = [connection]
    }
    
    func connect(_ conn: Connection) {
        print("Room connected for User.ID: ", conn.id)
        conn.room = self
        conn.onConnection()
        connections.insert(conn)
    }
    
    func disconnect(_ conn: Connection) {
        print("Room disconnected for User.ID: ", conn.id)
        connections.remove(conn)
    }
    
    func onBinary(_ data: Data, from conn: Connection) {
    }
    
    func onText(_ text: String, from conn: Connection) {
        
    }
    
    static func == (lhs: SocketRoom<RoomID, ConnectionID>, rhs: SocketRoom<RoomID, ConnectionID>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

}
