//
//  ConversationUser.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-13.
//

import Vapor
import FluentMySQL

public final class ConversationUser: Object, ModifiablePivot {
    
    public typealias Left = Conversation
    public typealias Right = User
    
    public static var leftIDKey: LeftIDKey = \ConversationUser.conversationId
    public static var rightIDKey: RightIDKey = \ConversationUser.userId
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var userId: User.ID
    public var conversationId: Conversation.ID
    public var isConnected: Bool?
    
    // MARK: - Public Version
    
    public struct Public: Codable, Content {
        
        public var updatedAt: Date?
        public var userId: User.ID
        
    }
    
    public func mapToPublic() -> Public {
        return Public(updatedAt: updatedAt,
                      userId: userId)
    }
    
    // MARK: - Initialization
    
    public init(userId: User.ID, conversationId: Conversation.ID) {
        self.userId = userId
        self.conversationId = conversationId
    }
    
    public init(_ left: Conversation, _ right: User) throws {
        self.userId = try right.requireID()
        self.conversationId = try left.requireID()
    }
    
    
    // MARK: - Relations
    
    internal var conversation: Parent<ConversationUser, Conversation> {
        return parent(\ConversationUser.conversationId)
    }
    
    internal var user: Parent<ConversationUser, User> {
        return parent(\ConversationUser.userId)
    }
    
    // MARK: - Life Cycle
    
    public func willCreate(on conn: MySQLConnection) throws -> EventLoopFuture<ConversationUser> {
        try setDefaultCreateProperties(on: conn)
        isConnected = false
        return conn.future(self)
    }
    
//    public static func <== (lhs: ConversationUser, rhs: ConversationUser) {
//        lhs.conversationId = rhs.conversationId
//        lhs.userId = rhs.userId
//        lhs.isConnected = rhs.isConnected ?? lhs.isConnected
//    }
    
}

/// Allows `ConversationUser` to be used as a dynamic migration.
extension ConversationUser: Migration {
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \ConversationUser.userId, to: \User.id, onUpdate: ._cascade, onDelete: ._cascade)
            builder.reference(from: \ConversationUser.conversationId, to: \Conversation.id, onUpdate: ._cascade, onDelete: ._cascade)
        }
    }
    
}
