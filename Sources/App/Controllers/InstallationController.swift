import Vapor
import Fluent

final class InstallationController: RouteCollection {
    
    func boot(router: Router) throws {
        
        router.group(SecretMiddleware.self) { protectedRouter in
            
            let groupedRoutes = protectedRouter.grouped(Installation.path)
            
            let tokenAuthMiddleware = User.tokenAuthMiddleware()
            let guardAuthMiddleware = User.guardAuthMiddleware()
            let tokenAuthGroup = groupedRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
            
            tokenAuthGroup.get(use: list)
            tokenAuthGroup.get(Installation.parameter, use: index)
            tokenAuthGroup.post(use: create)
            tokenAuthGroup.put(Installation.parameter, use: update)
            tokenAuthGroup.delete(Installation.parameter, use: delete)
            
        }
        
    }
    
    func list(_ req: Request) throws -> Future<[Installation.Public]> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        
        return try user.installations.query(on: req).sort(\.createdAt).all().flatMap(to: [Installation.Public].self) { installations in
            return installations.map { installation in
                return Future.map(on: req) { installation }.mapToPublic(on: req)
            }.flatten(on: req)
        }
    }

    func index(_ req: Request) throws -> Future<Installation.Public> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        let userId = try user.requireID()
        
        return try req.parameters.next(Installation.self).map(to: Installation.self) { installation in
            guard installation.userId == userId else {
                throw Abort(.unauthorized)
            }
            return installation
        }.mapToPublic(on: req)
    }
    
    func create(_ req: Request) throws -> Future<Installation.Public> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        let userId = try user.requireID()
        
        return try req.content.decode(Installation.self).flatMap(to: Installation.Public.self) { installation in
            installation.userId = userId
            return installation.save(on: req).mapToPublic(on: req)
        }
    }
    
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        let userId = try user.requireID()
        
        return try req.parameters.next(Installation.self).flatMap(to: HTTPStatus.self) { installation in
            guard installation.userId == userId else {
                throw Abort(.unauthorized)
            }
            return installation.delete(on: req).transform(to: .ok)
        }
        
    }
    
    func update(_ req: Request) throws -> Future<Installation.Public> {
        return try flatMap(to: Installation.Public.self, req.parameters.next(Installation.self), req.content.decode(Installation.self), { lhs, rhs in
            lhs.timeZone = rhs.timeZone ?? lhs.timeZone
            lhs.appIdentifier = rhs.appIdentifier ?? lhs.appIdentifier
            lhs.appVersion = rhs.appVersion ?? lhs.appVersion
            lhs.deviceType = rhs.deviceType ?? lhs.deviceType
            lhs.localeIdentifier = rhs.localeIdentifier ?? lhs.localeIdentifier
            lhs.deviceToken = rhs.deviceToken
            lhs.userId = rhs.userId
            return lhs.update(on: req).mapToPublic(on: req)
        })
    }
    
}
