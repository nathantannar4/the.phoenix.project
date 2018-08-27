import Vapor
import FluentMySQL

public final class Installation: Object {
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var timeZone: String?
    public var appVersion: Double?
    public var appIdentifier: String?
    public var deviceType: String?
    public var deviceToken: String
    public var localeIdentifier: String?
    public var userId: User.ID
    
    // MARK: - Initialization
    
    public init(deviceToken: String, userId: User.ID) {
        self.deviceToken = deviceToken
        self.userId = userId
    }
    
    // MARK: - Public Version
    
    public struct Public: Content {
        
        public var id: String?
        public var createdAt: Date?
        public var updatedAt: Date?
        public var timeZone: String?
        public var appVersion: Double?
        public var appIdentifier: String?
        public var deviceType: String?
        public var deviceToken: String?
        public var localeIdentifier: String?
        public var user: User.Public?
        
    }
    
    func mapToPublic(user: User) -> Public {
        return Public(id: id,
                      createdAt: createdAt,
                      updatedAt: updatedAt,
                      timeZone: timeZone,
                      appVersion: appVersion,
                      appIdentifier: appIdentifier,
                      deviceType: deviceType,
                      deviceToken: deviceToken,
                      localeIdentifier: localeIdentifier,
                      user: user.mapToPublic())
    }

    // MARK: - Relations
    
    internal var user: Parent<Installation, User> {
        return parent(\Installation.userId)
    }
    
}

/// Allows `Installation` to be used as a dynamic migration.
extension Installation: Migration {
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \Installation.userId, to: \User.id, onUpdate: ._cascade, onDelete: ._cascade)
        }
    }
    
}

extension Future where T: Installation {
    
    public func mapToPublic(on req: Request) -> Future<Installation.Public> {
        return self.flatMap(to: Installation.Public.self) { installation in
            return installation.user.get(on: req).map(to: Installation.Public.self) { user in
                return installation.mapToPublic(user: user)
            }
        }
    }
    
}
