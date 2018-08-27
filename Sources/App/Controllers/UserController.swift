import Vapor
import Authentication
import Crypto
import SendGrid

final class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group(SecretMiddleware.self) { protectedRouter in
            
            let groupedRoutes = protectedRouter.grouped(User.path)
            groupedRoutes.get(use: list)
            groupedRoutes.get(User.parameter, use: index)
            
            let tokenAuthMiddleware = User.tokenAuthMiddleware()
            let guardAuthMiddleware = User.guardAuthMiddleware()
            let tokenAuthGroup = groupedRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
            tokenAuthGroup.put(User.parameter, use: update)
            tokenAuthGroup.delete(User.parameter, use: delete)
            tokenAuthGroup.post("image", use: uploadImage)
            
        }
        
    }
    
    open func list(_ req: Request) throws -> Future<[User.Public]> {
        return User.query(on: req).sort(\.createdAt).all().flatMap(to: [User.Public].self) { users in
            return users.map { user in
                Future.map(on: req) { user }.mapToPublic(on: req)
            }.flatten(on: req)
        }
    }
    
    open func index(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).mapToPublic(on: req)
    }
    
    open func delete(_ req: Request) throws -> Future<HTTPStatus> {
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        return user.delete(on: req).transform(to: .ok)
    }
    
    open func update(_ req: Request) throws -> Future<User.Public> {
        guard let lhs = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        return try req.content.decode(User.self).flatMap(to: User.Public.self) { rhs in
            lhs.email = rhs.email ?? lhs.email
            lhs.username = rhs.username
            lhs.isEmailVerified = rhs.isEmailVerified ?? lhs.isEmailVerified
            lhs.imageId = rhs.imageId ?? lhs.imageId
            return lhs.update(on: req).mapToPublic(on: req)
        }
    }
    
    open func uploadImage(_ req: Request) throws -> Future<FileRecord.Public> {
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        return try FileController.upload(req).flatMap(to: FileRecord.Public.self) { record in
            user.imageId = try record.requireID()
            return user.save(on: req).map(to: FileRecord.Public.self) { _ in
                return record.mapToPublic()
            }
        }
    }
    
}
