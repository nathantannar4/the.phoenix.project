import Vapor
import FluentMySQL

public final class FileRecord: Object {
    
    public static var path: [PathComponentsRepresentable] {
        return ["files"]
    }
    
    // MARK: - Properties
    
    public var id: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    public var deletedAt: Date?
    public var filename: String
    public var fileKind: String?
    public var localPath: String

    // MARK: - Initialization
    
    public init(filename: String, fileKind: String?, localPath: String) {
        self.filename = filename
        self.localPath = localPath
        self.fileKind = fileKind
    }

    // MARK: - Public
    
    public struct Public: Codable, Content {
        
        public var filename: String
        public var fileKind: String?
        public var publicURL: URL?
        
    }
    
    public func mapToPublic() -> Public {
        if let id = id {
            let host = Environment.PUBLIC_URL
            let publicURL = URL(string: host)?.appendingPathComponent("\(FileRecord.path.convertToPathComponents().readable)/\(id)")
            return Public(filename: filename, fileKind: fileKind, publicURL: publicURL)
        }
        return Public(filename: filename, fileKind: fileKind, publicURL: nil)
    }
    
    // MARK: - ObjectModel
    
//    public static func <== (lhs: FileRecord, rhs: FileRecord) {
//        lhs.filename = rhs.filename
//        lhs.localPath = rhs.localPath
//        lhs.fileKind = rhs.fileKind ?? lhs.fileKind
//    }
    
    
}

extension Future where T: FileRecord {
    
    public func mapToPublic() -> Future<FileRecord.Public> {
        return self.map(to: FileRecord.Public.self) { record in
            return record.mapToPublic()
        }
    }
    
}
