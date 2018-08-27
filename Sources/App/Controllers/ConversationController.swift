import Vapor
import FluentMySQL

final class ConversationController: RouteCollection{
    
    func boot(router: Router) throws {
        
        router.group(SecretMiddleware.self) { protectedRouter in
            
            let groupedRoutes = protectedRouter.grouped(Conversation.path)
            
            let tokenAuthMiddleware = User.tokenAuthMiddleware()
            let guardAuthMiddleware = User.guardAuthMiddleware()
            let tokenAuthGroup = groupedRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
            
            tokenAuthGroup.get(use: list)
            tokenAuthGroup.get(Conversation.parameter, use: index)
            tokenAuthGroup.post(use: create)
            tokenAuthGroup.put(Conversation.parameter, use: update)
            tokenAuthGroup.delete(Conversation.parameter, use: delete)
            tokenAuthGroup.get(Conversation.parameter, Message.path, use: listMessages)
            tokenAuthGroup.get(Conversation.parameter, User.path, use: listUsers)
            tokenAuthGroup.post(Conversation.parameter, "join", use: join)
            tokenAuthGroup.post(Conversation.parameter, "leave", use: leave)
            tokenAuthGroup.post(Conversation.parameter, Message.path, use: createMessage)
            
        }
        
    }
    
    func list(_ req: Request) throws -> Future<[Conversation.Detail]> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try user.conversations.query(on: req).sort(\.createdAt).all().flatMap(to: [Conversation.Detail].self) { conversations in
                return try conversations.map { return try $0.mapToDetail(on: req) }.flatten(on: req)
        }
    }
    
    func index(_ req: Request) throws -> Future<Conversation.Detail> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try req.parameters.next(Conversation.self).flatMap(to: Conversation.Detail.self) { conversation in
            
            return conversation.users.isAttached(user, on: req).flatMap(to: Conversation.Detail.self) { isMember in
                guard isMember else {
                    throw Abort(.badRequest)
                }
                return try conversation.mapToDetail(on: req)
            }
        }
    }
    
    func create(_ req: Request) throws -> Future<Conversation.Detail> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try req.content.decode(Conversation.self).save(on: req).flatMap(to: Conversation.Detail.self) { conversation in
            
            let userId = try user.requireID()
            let member = try ConversationUser(userId: userId, conversationId: conversation.requireID())
            return member.save(on: req).map(to: Conversation.Detail.self) { _ in
                return conversation.mapToDetail(users: [user.mapToPublic()], connectedUsers: [], lastMessage: nil)
            }
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Conversation.self).delete(on: req).transform(to: .ok)
    }
    
    func update(_ req: Request) throws -> Future<Conversation.Detail> {
        return try flatMap(to: Conversation.Detail.self, req.parameters.next(Conversation.self), req.content.decode(Conversation.self), { model, updatedModel in
            model.name = updatedModel.name ?? model.name
            return model.update(on: req).mapToPublic(on: req)
        })
    }
    
    func join(_ req: Request) throws -> Future<ConversationUser> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try req.parameters.next(Conversation.self).flatMap(to: ConversationUser.self) { conversation in
            
            let userId = try user.requireID()
            
            return conversation.users.isAttached(user, on: req).flatMap(to: ConversationUser.self) { isMember in
                guard !isMember else {
                    throw Abort(.badRequest)
                }
                let member = try ConversationUser(userId: userId, conversationId: conversation.requireID())
                return member.save(on: req)
            }
        }
    }
    
    func leave(_ req: Request) throws -> Future<HTTPStatus> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try req.parameters.next(Conversation.self).flatMap(to: HTTPStatus.self) { conversation in
            
            let userId = try user.requireID()
            return try conversation.users.query(on: req).filter(\ConversationUser.userId == userId).first().unwrap(or: Abort(.badRequest)).flatMap(to: HTTPStatus.self) { member in
                return member.delete(on: req).transform(to: .ok)
            }
        }
    }
    
    func listMessages(_ req: Request) throws -> Future<[Message.Detail]> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try req.parameters.next(Conversation.self).flatMap(to: [Message.Detail].self) { conversation in
            return conversation.users.isAttached(user, on: req).flatMap(to: [Message.Detail].self) { isMember in
                guard isMember else {
                    throw Abort(.forbidden)
                }
                return try conversation.messages.query(on: req).sort(\.createdAt).all().flatMap(to: [Message.Detail].self) { messages in
                    return messages.map { message in
                        Future.map(on: req) { message }.mapToDetail(on: req)
                    }.flatten(on: req)
                }
            }
        }
    }
    
    func listUsers(_ req: Request) throws -> Future<[User.Public]> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try req.parameters.next(Conversation.self).flatMap(to: [User.Public].self) { conversation in
            return conversation.users.isAttached(user, on: req).flatMap(to: [User.Public].self) { isMember in
                guard isMember else {
                    throw Abort(.forbidden)
                }
                return try conversation.users.query(on: req).sort(\.createdAt).all().map(to: [User.Public].self) { users in
                    return users.map { $0.mapToPublic() }
                }
            }
        }
    }
    
    func createMessage(_ req: Request) throws -> Future<Message.Detail> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try flatMap(to: Message.Detail.self, req.parameters.next(Conversation.self), req.content.decode(Message.self)) { conversation, message in
            
            return conversation.users.isAttached(user, on: req).flatMap(to: Message.Detail.self) { isMember in
                
                guard isMember else {
                    throw Abort(.forbidden)
                }
                
                message.userId = try user.requireID()
                message.conversationId = try conversation.requireID()
                return message.save(on: req).mapToDetail(on: req)
            }
        }
    }
    
}
