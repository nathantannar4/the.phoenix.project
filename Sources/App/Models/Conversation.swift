//
//  Conversation.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-13.
//

import Vapor
import FluentMySQL

public final class Conversation: Object {
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var name: String?
    
    // MARK: - Detail Version
    
    public struct Detail: Codable, Content {
        
        public var id: String?
        public var createdAt: Date?
        public var updatedAt: Date?
        public var name: String?
        public var connectedUsers: [ConversationUser.Public]?
        public var users: [User.Public]?
        public var lastMessage: Message.Detail?
        
    }
    
   public func mapToDetail(users: [User.Public]?, connectedUsers: [ConversationUser.Public]?, lastMessage: Message.Detail?) -> Detail {
        return Detail(id: id,
                      createdAt: createdAt,
                      updatedAt: updatedAt,
                      name: name,
                      connectedUsers: connectedUsers,
                      users: users,
                      lastMessage: lastMessage)
    }
    
    public func mapToDetail(on conn: DatabaseConnectable) throws -> Future<Conversation.Detail> {
        let fUsers = try self.users.query(on: conn).all()
        let fConnectedUsers = try self.users.pivots(on: conn)
            .filter(\.isConnected == true)
            .decode(data: ConversationUser.Public.self)
            .all()
        let fMessage = try self.messages.query(on: conn).sort(\.createdAt, ._descending).first()
        return flatMap(to: Conversation.Detail.self, fUsers, fConnectedUsers, fMessage, { users, connectedUsers, lastMessage in
            if let lastMessage = lastMessage {
                return lastMessage.user.get(on: conn).flatMap(to: Conversation.Detail.self) { lastMessageUser in
                    let publicLastMessageUser = lastMessageUser.mapToPublic()
                    return Future.map(on: conn) {
                        let publicUsers = users.map { $0.mapToPublic() }
                        let detailMessage = lastMessage.mapToDetail(user: publicLastMessageUser)
                        return self.mapToDetail(users: publicUsers, connectedUsers: connectedUsers, lastMessage: detailMessage)
                    }
                }
            } else {
                return Future.map(on: conn) {
                    let publicUsers = users.map { $0.mapToPublic() }
                    return self.mapToDetail(users: publicUsers, connectedUsers: connectedUsers, lastMessage: nil)
                }
            }
        })
    }

    // MARK: - Relations
    
    internal var users: Siblings<Conversation, User, ConversationUser> {
        return siblings()
    }
    
    internal var messages: Children<Conversation, Message> {
        return children(\Message.conversationId)
    }
    
    // MARK: Socket Helper Methods
    
    @discardableResult
    internal func didConnectOverSocket(_ userId: User.ID, on conn: DatabaseConnectable) throws -> Future<HTTPStatus> {
        
        return try users.pivots(on: conn)
            .filter(\ConversationUser.userId == userId)
            .first()
            .flatMap(to: ConversationUser.self) { member in
                guard let member = member else { throw Abort(.notFound) }
                member.isConnected = true
                return member.save(on: conn)
            }.transform(to: .ok)
    }
    
    @discardableResult
    internal func didDisconnectOverSocket(_ userId: User.ID, on conn: DatabaseConnectable) throws -> Future<HTTPStatus> {
        
        return try users.pivots(on: conn)
            .filter(\ConversationUser.userId == userId)
            .first()
            .flatMap(to: ConversationUser.self) { member in
                guard let member = member else { throw Abort(.notFound) }
                member.isConnected = false
                return member.save(on: conn)
            }.transform(to: .ok)
        }
    
}


extension Future where T: Conversation {
    
    public func mapToPublic(on req: Request) -> Future<Conversation.Detail> {
        return self.flatMap(to: Conversation.Detail.self) { conversation in
            return try conversation.mapToDetail(on: req)
        }
    }
    
}


