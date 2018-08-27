import Vapor
import Authentication
import FluentMySQL
import Crypto

public final class User: Object {
 
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var username: String
    public var password: String
    public var email: String?
    public var isEmailVerified: Bool?
    public var imageId: FileRecord.ID?
    
    // MARK: - Initialization
    
    public init(username: String, password: String, email: String? = nil) throws {
        self.username = username
        self.password = try BCryptDigest().hash(password)
        self.email = email
    }
    
    // MARK: - Public Version
    
    public struct Public: Codable, Content {
        
        public var id: String?
        public var createdAt: Date?
        public var updatedAt: Date?
        public var username: String
        public var email: String?
        public var isEmailVerified: Bool?
        public var image: FileRecord.Public?
        
    }
    
    public func mapToPublic(image: FileRecord.Public? = nil) -> Public {
        return Public(id: id,
                      createdAt: createdAt,
                      updatedAt: updatedAt,
                      username: username,
                      email: email,
                      isEmailVerified: isEmailVerified,
                      image: image)
    }
    
    // MARK: - Relations
    
    internal var installations: Children<User, Installation> {
        return children(\Installation.userId)
    }
    
    internal var messages: Children<User, Message> {
        return children(\Message.userId)
    }
    
    internal var image: Parent<User, FileRecord>? {
        return parent(\User.imageId)
    }
    
    internal var conversations: Siblings<User, Conversation, ConversationUser> {
        return siblings()
    }
    
    // MARK: - Life Cycle
    
    public func willCreate(on conn: MySQLConnection) throws -> EventLoopFuture<User> {
        try setDefaultCreateProperties(on: conn)
        isEmailVerified = false
        return conn.future(self)
    }
    
}

extension User: Migration {
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username)
            builder.reference(from: \User.imageId, to: \FileRecord.id, onUpdate: ._cascade, onDelete: ._cascade)
        }
    }
    
}

extension User: BasicAuthenticatable {
    
    public static var usernameKey: WritableKeyPath<User, String> {
        return \User.username
    }
    
    public static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
    
}

extension User: TokenAuthenticatable {
    
    public typealias TokenType = BearerToken
    
    public static func authenticate(using bearer: BearerAuthorization, on conn: DatabaseConnectable) -> Future<BearerToken?> {
        return BearerToken.query(on: conn).filter(TokenType.tokenKey == bearer.token).filter(\BearerToken.expiresAt >= Date()).first()
    }

}

extension User: SessionAuthenticatable {}

extension User: PasswordAuthenticatable {}

extension Future where T: User {
    
    public func mapToPublic(on req: Request) -> Future<User.Public> {
        return self.flatMap(to: User.Public.self) { user in
            if let imageRelation = user.image {
                return imageRelation.get(on: req).map(to: User.Public.self) { image in
                    return user.mapToPublic(image: image.mapToPublic())
                }
            } else {
                return self.map(to: User.Public.self) { user in
                    return user.mapToPublic()
                }
            }
        }
    }
    
}
