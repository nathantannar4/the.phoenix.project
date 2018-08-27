import Vapor
import FluentMySQL
import Crypto

public final class VerifyToken: Object {
    
    public enum Kind: Int, Encodable, Decodable {
        case emailVerification
        case passwordreset
    }
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var value: String
    public var userId: User.ID
    public var expiresAt: Date
    public var kind: Kind
    
    // MARK: - Initialization
    
    public init(value: String, userId: User.ID, kind: Kind) {
        self.value = value
        self.userId = userId
        self.expiresAt = Date().addingTimeInterval(60*60*24*2) // 2 Days
        self.kind = kind
    }
    
    public convenience init(userId: User.ID, kind: Kind) throws {
        let value = try CryptoRandom().generateData(count: 16).base64URLEncodedString()
        self.init(value: value, userId: userId, kind: kind)
    }
    
    public convenience init(user: User, kind: Kind) throws {
        let value = try CryptoRandom().generateData(count: 16).base64URLEncodedString()
        let userId = try user.requireID()
        self.init(value: value, userId: userId, kind: kind)
    }
    
    // MARK: - Public
    
    public func mapToPublic() -> String {
        return value
    }
    
    // MARK: - Relations
    
    internal var user: Parent<VerifyToken, User> {
        return parent(\VerifyToken.userId)
    }
    
    
    // MARK: - Life Cycle
    
    public func willCreate(on conn: MySQLConnection) throws -> EventLoopFuture<VerifyToken> {
        try setDefaultCreateProperties(on: conn)
        expiresAt = Date().addingTimeInterval(60*60*24*2) // 2 Days
        return conn.future(self)
    }
//    public static func <== (lhs: VerifyToken, rhs: VerifyToken) {
//        lhs.value = rhs.value
//        lhs.userId = rhs.userId
//        lhs.expiresAt = rhs.expiresAt
//    }
    
}

/// Allows `Token` to be used as a dynamic migration.
extension VerifyToken: Migration {
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \VerifyToken.userId, to: \User.id, onUpdate: ._cascade, onDelete: ._cascade)
        }
    }
    
}

extension Future where T: VerifyToken {
    
    public func mapToPublic() -> Future<String> {
        return self.map(to: String.self) { verifyToken in
            return verifyToken.mapToPublic()
        }
    }
    
}
