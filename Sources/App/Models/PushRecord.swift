import Vapor
import FluentMySQL

public final class PushRecord: Object {
    
    public static var path: [PathComponentsRepresentable] {
        return ["push"]
    }
    
    public enum DeliveryStatus: Int, Codable {
        case delivered = 1
        case deliveryFailed = 0
    }
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var payload: APNSPayload
    public var installationId: Installation.ID?
    public var status: DeliveryStatus
    public var error: String?
    public var sentBy: User.ID?
    
    // MARK: - Initialization
    
    public init(payload: APNSPayload, installationId: Installation.ID?, status: DeliveryStatus, sentBy: User.ID?) {
        self.payload = payload
        self.installationId = installationId
        self.status = status
        self.sentBy = sentBy
    }
    
    public init(payload: APNSPayload, installationId: Installation.ID?, error: APNSError, sentBy: User.ID?) {
        self.payload = payload
        self.installationId = installationId
        self.status = .deliveryFailed
        self.error = error.rawValue
        self.sentBy = sentBy
    }
    
    
    // MARK: - Public
    
    public struct Public: Codable, Content {
        
        public let status: DeliveryStatus
        public let error: String?
        
    }
    
    func mapToPublic() -> Public {
        return Public(status: status, error: error)
    }
    
    // MARK: - Relations
    
    internal var installation: Parent<PushRecord, Installation>? {
        return parent(\PushRecord.installationId)
    }

}

extension PushRecord: Migration {
    
    public static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \PushRecord.installationId, to: \Installation.id, onUpdate: ._cascade, onDelete: ._setNull)
            builder.reference(from: \PushRecord.sentBy, to: \User.id, onUpdate: ._cascade, onDelete: ._setNull)
        }
    }
    
}

extension Future where T: PushRecord {
    
    public func mapToPublic() -> Future<PushRecord.Public> {
        return self.map(to: PushRecord.Public.self) { record in
            return record.mapToPublic()
        }
    }
    
}
