//
//  ConversationManager.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-15.
//

import Vapor

class ConversationManager: SocketManager {
    
    typealias RoomID = Conversation.ID
    typealias ConnectionID = User.ID
    
    typealias Room = SocketRoom<RoomID, ConnectionID>
    
    var rooms: Set<Room>
    
    init() {
        self.rooms = []
    }
    
    func interceptConnection(_ conn: ConversationConnection, to roomId: RoomID, fallback: (ConversationConnection) throws -> Room) throws {
        print("Intercepting connection for RoomID: ", roomId)
        
        if let index = rooms.index(where: { $0.id == roomId }) {
            print("Joining existing room for RoomID: ", roomId)
            rooms[index].connect(conn)
        } else {
            print("Creating room for RoomID: ", roomId)
            let room = try fallback(conn)
            room.connect(conn)
            rooms.insert(room)
        }
        
        print("Room Count at: ", rooms.count)
        
    }
    
}
