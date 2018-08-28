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
        
        if let index = rooms.index(where: { $0.id == roomId }) {
            rooms[index].connect(conn)
        } else {
            let room = try fallback(conn)
            room.connect(conn)
            rooms.insert(room)
        }
    }
    
}
