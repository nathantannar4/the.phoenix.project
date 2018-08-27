//
//  ConversationRoom.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-15.
//

import Vapor
import Fluent

class ConversationRoom: SocketRoom<IDType, IDType> {
    
    let conversation: Conversation
    
    init(conversation: Conversation, connection: Connection) throws {
        self.conversation = conversation
        super.init(id: try conversation.requireID(), connection: connection)
    }
    
    func syncConversation() {
        guard let conn = connections.first?.conn, let id = conversation.id else { return }
        _ = Conversation.query(on: conn)
            .filter(\Conversation.id == id)
            .first().unwrap(or: Abort(.notFound))
            .flatMap(to: Conversation.Detail.self) { conversation in
                return try conversation.mapToDetail(on: conn)
            }.thenThrowing { [weak self] conversation in
                guard let connections = self?.connections else { return }
                let data = try JSONEncoder.encode(conversation)
                connections.forEach { $0.ws.send(data) }
        }
    }
    
    override func connect(_ conn: Connection) {
        super.connect(conn)
        print("Conversation.ID: ", id, " connected user for User.ID: ", conn.id)
    }
    
    override func disconnect(_ conn: Connection) {
        super.disconnect(conn)
        print("Conversation.ID: ", id, " disconnected user for User.ID: ", conn.id)
    }
    
    override func onBinary(_ data: Data, from conn: Connection) {
        print("onBinary from User.ID: ", conn.id)
        do {
            let message = try JSONDecoder.decode(Message.self, from: data)
            message.save(on: conn.conn).thenThrowing { [weak self] message in
                guard let connections = self?.connections else { return }
                let data = try JSONEncoder.encode(message)
                print("Current connection count: ", connections.count)
                connections.forEach { $0.ws.send(data) }
            }.catch { error in
                conn.onError(conn.ws, error)
            }
        } catch (let error) {
            conn.onError(conn.ws, error)
        }
    }
    
    override func onText(_ text: String, from conn: Connection) {
        print("onText from User.ID: ", conn.id)
        Message(text: text, userId: conn.id, conversationId: id)
            .save(on: conn.conn)
            .thenThrowing { [weak self] message in
                guard let connections = self?.connections else { return }
                print("Current connection count: ", connections.count)
                let data = try JSONEncoder.encode(message)
                connections.forEach { $0.ws.send(data) }
            }.catch { error in
                conn.onError(conn.ws, error)
        }
    }
    
}

extension JSONEncoder {
    
    static func encode<T:Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        if #available(OSX 10.12, *) {
            encoder.dateEncodingStrategy = .iso8601
        }
        return try encoder.encode(value)
    }
    
}

extension JSONDecoder {
    
    static func decode<T:Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        if #available(OSX 10.12, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return try decoder.decode(type, from: data)
    }
    
}
