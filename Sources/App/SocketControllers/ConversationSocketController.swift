//
//  ConversationSocketController.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-14.
//

import Vapor
import Fluent

final class ConversationSocketController: SocketCollection {
    
    private var manager = ConversationManager()
    
    func boot(wss: NIOWebSocketServer) throws {
   
        wss.get(Conversation.path, Conversation.parameter, User.parameter, use: routeHandler)
    }
    
    func routeHandler(_ ws: WebSocket, _ req: Request) throws {
        
//        guard let user = try req.authenticated(User.self) else {
//            throw Abort(.unauthorized)
//        }
        
        try req.parameters.next(Conversation.self).and(req.parameters.next(User.self)).map { [weak self] result in
            
            let (conversation, user) = result
            
//            conversation.users.isAttached(user, on: req).map { isMember in
//
//                guard isMember else {
//                    throw Abort(.badRequest)
//                }
            
                let conn = try ConversationConnection(user: user, ws: ws, conn: req)
                try self?.manager.interceptConnection(conn, to: conversation.requireID(), fallback: { conn in
                    return try ConversationRoom(conversation: conversation, connection: conn)
                })
                
//            }
                
        }.catch { error in
            ws.close(code: .unexpectedServerError)
        }
    }

}
