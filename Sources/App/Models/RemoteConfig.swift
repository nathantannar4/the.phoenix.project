import Vapor
import FluentMySQL

public final class RemoteConfig: Object {
    
    public static var path: [PathComponentsRepresentable] {
        return ["config"]
    }
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var key: String
    public var value: String
    
    // MARK: - Initialization
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    // MARK: - Public
    
    public struct Public: Codable, Content {
        
        public var id: String?
        public var createdAt: Date?
        public var updatedAt: Date?
        public var key: String
        public var value: String
        
    }
    
    public func mapToPublic() -> Public {
        return Public(id: id,
                      createdAt: createdAt,
                      updatedAt: updatedAt,
                      key: key,
                      value: value)
    }
    
}


extension Future where T: RemoteConfig {
    
    public func mapToPublic() -> Future<RemoteConfig.Public> {
        return self.map(to: RemoteConfig.Public.self) { config in
            return config.mapToPublic()
        }
    }
    
}
