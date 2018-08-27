//
//  ConversationConnection.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-15.
//

import Vapor

class ConversationConnection: SocketConnection<IDType, IDType> {
    
    let user: User
    
    var conversationRoom: ConversationRoom? {
        return room as? ConversationRoom
    }
    
    init(user: User, ws: WebSocket, conn: DatabaseConnectable) throws {
        self.user = user
        super.init(id: try user.requireID(), ws: ws, conn: conn)
    }
    
    override func onConnection() {
        super.onConnection()
        _ = try? conversationRoom?.conversation.didConnectOverSocket(user.requireID(), on: conn).do { [weak self] _ in
            self?.conversationRoom?.syncConversation()
        }
    }
    
    override func onDisconnection() {
        super.onDisconnection()
        _ = try? conversationRoom?.conversation.didDisconnectOverSocket(user.requireID(), on: conn).do { [weak self] _ in
            self?.conversationRoom?.syncConversation()
        }
    }
    
}
