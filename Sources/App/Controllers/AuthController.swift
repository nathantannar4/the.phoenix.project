import Vapor
import Fluent
import Authentication
import Crypto
import SendGrid

final class AuthController: RouteCollection {
    
    func boot(router: Router) throws {
        
        let groupedRoutes = router.grouped("auth")
  
        groupedRoutes.get("verify", "email", String.parameter, use: verifyEmail)
        groupedRoutes.get("reset", "password", String.parameter, use: resetPassword)
        
        groupedRoutes.group(SecretMiddleware.self) { protectedRouter in
            
            protectedRouter.post("register", use: register)
            protectedRouter.post("request", "passwordreset", use: requestPasswordReset)
        
            let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
            let basicAuthGroup = protectedRouter.grouped(basicAuthMiddleware, User.guardAuthMiddleware())
            basicAuthGroup.post("login", use: login)
            
            let tokenAuthMiddleware = User.tokenAuthMiddleware()
            let tokenAuthGroup = protectedRouter.grouped(tokenAuthMiddleware, User.guardAuthMiddleware())
            tokenAuthGroup.post("logout", use: logout)
            tokenAuthGroup.get("verify", "login", use: verifyLogin)
            tokenAuthGroup.post("verify", "email", use: requestVerificationEmail)
            tokenAuthGroup.put("reset", "password", use: updatePassword)
            
        }
    }
    
    func register(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap(to: User.Public.self) { user in
            return User.query(on: req).filter(\User.username == user.username).first().flatMap { result in
                guard result == nil else {
                    throw Abort(.notAcceptable)
                }
                user.password = try BCryptDigest().hash(user.password)
                return user.save(on: req).map(to: User.Public.self) { user in
                    do {
                        _ = try self.requestVerificationEmail(req)
                    } catch {}
                    return user.mapToPublic()
                }
                
            }
        }
    }
    
    func login(_ req: Request) throws -> Future<BearerToken.Public> {
        let user = try req.requireAuthenticated(User.self)
        try req.authenticateSession(user)
        let token = try BearerToken(user: user)
        return token.save(on: req).mapToPublic()
    }
    
    func verifyLogin(_ req: Request) throws -> Future<User.Public> {
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        return Future.map(on: req) { user.mapToPublic() }
    }
    
    func logout(_ req: Request) throws -> Future<HTTPStatus> {
        guard let token = try req.authenticated(BearerToken.self) else {
            throw Abort(.unauthorized)
        }
        try req.unauthenticateSession(User.self)
        return token.delete(on: req).transform(to: .ok)
    }
    
    func updatePassword(_ req: Request) throws -> Future<HTTPStatus> {
        guard let user = try req.authenticated(User.self) else {
            throw Abort(.unauthorized)
        }
        return try req.content.decode(User.self).flatMap { decodedUser in
            guard decodedUser.username == user.username else {
                throw Abort(.unauthorized)
            }
            user.password = try BCryptDigest().hash(decodedUser.password)
            let userId = try user.requireID()
            return user.update(on: req)
                .and(BearerToken.query(on: req).filter(\BearerToken.userId == userId).delete())
                .transform(to: .ok)
        }
    }
    
    func decodeVerifyToken(_ req: Request) throws -> Future<VerifyToken> {
        
        let token = try req.parameters.next(String.self)
        return VerifyToken.query(on: req).filter(\VerifyToken.value == token).first().unwrap(or: Abort(.notFound))
    }
    
    func resetPassword(_ req: Request) throws -> Future<String> {
        return try self.decodeVerifyToken(req).flatMap(to: String.self) { token in
            guard token.expiresAt >= Date() else {
                return Future.map(on: req) { "Password Reset Token Expired" }
            }
            return token.user.get(on: req).flatMap(to: String.self) { user in
                let temporaryPassword = try CryptoRandom().generateData(count: 16).base64EncodedString()
                user.password = try BCryptDigest().hash(temporaryPassword)
                token.expiresAt = Date()
                let userId = try user.requireID()
                return user.update(on: req)
                    .and(token.update(on: req))
                    .and(BearerToken.query(on: req).filter(\BearerToken.userId == userId).delete())
                    .transform(to: "Temporary Password: " + temporaryPassword)
            }
        }
    }
    
    func requestPasswordReset(_ req: Request) throws -> Future<String> {
        
        guard Environment.SENDGRID_API_KEY != nil, Environment.NO_REPLY_EMAIL != nil else {
            throw Abort(.internalServerError)
        }
        
        return try req.content.decode(User.self).flatMap(to: String.self) { user in
            guard let email = user.email else {
                throw Abort(HTTPStatus.init(statusCode: 111, reasonPhrase: "Missing value for key 'email'"))
            }
            return User.query(on: req)
                .filter(\User.email == email)
                .filter(\User.username == user.username)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { user in
                    
                    return try VerifyToken(user: user, kind: .passwordreset).save(on: req).flatMap(to: String.self) { token in
                        
                        let to = EmailAddress(email: user.email, name: user.username)
                        let email = EmailTemplates.passwordReset(to: to, token: token.value)
                        let sendGridClient = try req.make(SendGridClient.self)
                        return try sendGridClient.send([email], on: req).transform(to: "Password Reset Link Sent")
                }
            }
        }
    }
    
    func verifyEmail(_ req: Request) throws -> Future<String> {
        return try self.decodeVerifyToken(req).flatMap(to: String.self) { token in
            guard token.expiresAt >= Date() else {
                return Future.map(on: req) { "Email Verification Token Expired" }
            }
            return token.user.get(on: req).flatMap(to: String.self) { user in
                    user.isEmailVerified = true
                    token.expiresAt = Date()
                    return user.update(on: req)
                        .and(token.update(on: req))
                        .transform(to: "Email Successfully Verified")
            }
        }
    }
    
    func requestVerificationEmail(_ req: Request) throws -> Future<String> {
        
        guard Environment.SENDGRID_API_KEY != nil, Environment.NO_REPLY_EMAIL != nil else {
            throw Abort(.internalServerError)
        }
        
        return try req.content.decode(User.Public.self)
            .catchMap { _ in
                guard let user = try req.authenticated(User.self) else {
                    throw Abort(.unauthorized)
                }
                return user.mapToPublic()
            }.flatMap(to: String.self) { user in
                guard let emailString = user.email else {
                    throw Abort(HTTPStatus.init(statusCode: 110, reasonPhrase: "User does not have an email to verify"))
                }
                guard let userId = user.id else {
                    throw Abort(.badRequest)
                }
                
                return try VerifyToken(userId: userId, kind: .emailVerification).save(on: req).flatMap(to: String.self) { token in
                    let to = EmailAddress(email: emailString, name: emailString)
                    let email = EmailTemplates.accountVerification(to: to, token: token.value)
                    let sendGridClient = try req.make(SendGridClient.self)
                    return try sendGridClient.send([email], on: req).transform(to: "Email Verification Link Sent")
                }
        }
    }
    
}
