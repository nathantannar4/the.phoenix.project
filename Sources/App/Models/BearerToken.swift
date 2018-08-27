import Foundation
import Vapor
import FluentMySQL
import Authentication

public final class BearerToken: Object {
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var value: String
    public var userId: User.ID
    public var expiresAt: Date?
    
    // MARK: - Initialization
    
    public init(value: String, userId: User.ID) {
        self.value = value
        self.userId = userId
    }
    
    public convenience init(userId: User.ID) throws {
        let value = try CryptoRandom().generateData(count: 16).base64EncodedString()
        self.init(value: value, userId: userId)
    }
    
    public convenience init(user: User) throws {
        let value = try CryptoRandom().generateData(count: 16).base64EncodedString()
        let userId = try user.requireID()
        self.init(value: value, userId: userId)
    }
    
    // MARK: - Public Version
    
    public struct Public: Codable, Content {

        public var createdAt: Date?
        public var updatedAt: Date?
        public var userId: String
        public var value: String
        public var expiresAt: Date?
        
    }
    
    public func mapToPublic() -> Public {
        return Public(createdAt: createdAt,
                      updatedAt: updatedAt,
                      userId: userId,
                      value: value,
                      expiresAt: expiresAt)
    }
    
    // MARK: - Relations
    
    internal var user: Parent<BearerToken, User> {
        return parent(\BearerToken.userId)
    }
    
    
    // MARK: - Life Cycle
    
    public func willCreate(on conn: MySQLConnection) throws -> EventLoopFuture<BearerToken> {
        try setDefaultCreateProperties(on: conn)
        expiresAt = Date().addingTimeInterval(60*60*24*180) // 180 Days
        return conn.future(self)
    }
    
}

/// Allows `Token` to be used as a dynamic migration.
extension BearerToken: Migration {
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \BearerToken.userId, to: \User.id, onUpdate: ._cascade, onDelete: ._cascade)
        }
    }
    
}

extension BearerToken: Authentication.Token {

    public static let userIDKey: UserIDKey = \BearerToken.userId
    
    public typealias UserType = User
}

extension BearerToken: BearerAuthenticatable {
    
    public static let tokenKey: TokenKey = \BearerToken.value

    public static func authenticate(using bearer: BearerAuthorization, on conn: DatabaseConnectable) -> Future<BearerToken?> {
        return BearerToken.query(on: conn).filter(tokenKey == bearer.token).filter(\BearerToken.expiresAt >= Date()).first()
    }
    
}

extension Future where T: BearerToken {
    
    public func mapToPublic() -> Future<BearerToken.Public> {
        return self.map(to: BearerToken.Public.self) { token in
            return token.mapToPublic()
        }
    }
    
}
