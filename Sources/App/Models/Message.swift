//
//  Message.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-13.
//


import Vapor
import FluentMySQL

public final class Message: Object {
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var text: String?
    public var fileId: FileRecord.ID?
    public var userId: User.ID
    public var conversationId: Conversation.ID
    
    // MARK: - Detail Version
    
    public struct Detail: Codable, Content {
        
        public var id: String?
        public var createdAt: Date?
        public var updatedAt: Date?
        public var text: String?
        public var file: FileRecord.Public?
        public var user: User.Public
        
    }
    
    public func mapToDetail(user: User.Public, file: FileRecord.Public? = nil) -> Detail {
        return Detail(id: id,
                      createdAt: createdAt,
                      updatedAt: updatedAt,
                      text: text,
                      file: file,
                      user: user)
    }
    
    // MARK: - Initialization
    
    public init(text: String?, userId: User.ID, conversationId: Conversation.ID) {
        self.text = text
        self.userId = userId
        self.conversationId = conversationId
    }
    
    // MARK: - Relations
    
    internal var conversation: Parent<Message, Conversation> {
        return parent(\Message.conversationId)
    }
    
    internal var user: Parent<Message, User> {
        return parent(\Message.userId)
    }
    
    internal var file: Parent<Message, FileRecord>? {
        return parent(\Message.fileId)
    }
    
//    public static func <== (lhs: Message, rhs: Message) {
//        lhs.conversationId = rhs.conversationId
//        lhs.userId = rhs.userId
//        lhs.text = rhs.text ?? lhs.text
//    }
    
}


/// Allows `Message` to be used as a dynamic migration.
extension Message: Migration {
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \Message.userId, to: \User.id, onUpdate: ._cascade, onDelete: ._cascade)
            builder.reference(from: \Message.conversationId, to: \Conversation.id, onUpdate: ._cascade, onDelete: ._cascade)
        }
    }
    
}

extension Future where T: Message {
    
    public func mapToDetail(on req: Request) -> Future<Message.Detail> {
        return self.flatMap(to: Message.Detail.self) { message in
            if let fileRelation = message.file {
                return message.user.get(on: req).flatMap(to: Message.Detail.self) { user in
                    return fileRelation.get(on: req).map(to: Message.Detail.self) { file in
                        return message.mapToDetail(user: user.mapToPublic(), file: file.mapToPublic())
                    }
                }
            } else {
                return message.user.get(on: req).map(to: Message.Detail.self) { user in
                    return message.mapToDetail(user: user.mapToPublic(), file: nil)
                }
            }
        }
    }
    
}


