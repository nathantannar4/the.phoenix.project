import Vapor
import SendGrid

final class RouteLoggingMiddleware: Middleware, Service {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        
        let logger = try request.make(Logger.self)

        let method = request.http.method
        let path = request.http.url.path
        let query = request.http.url.query ?? ""
        let body = request.http.body
        
        let reqString = "[ \(method) ]@\(path)?\(query) [ BODY ] \(body.debugDescription)"
        
        do {
            let workDir = DirectoryConfig.detect().workDir
            let logPath = Environment.LOG_PATH.convertToPathComponents().readable
            let path = URL(fileURLWithPath: workDir).appendingPathComponent(logPath, isDirectory: true)
            if !FileManager.default.fileExists(atPath: path.absoluteString) {
                try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            }
            let url = path.appendingPathComponent("access.log")
            try reqString.appendLineToURL(fileURL: url)
        } catch (let error) {
            logger.report(error: error)
        }
        
        logger.debug(reqString)
        return try next.respond(to: request)
    }
    
}

extension RouteLoggingMiddleware: ServiceType {
    
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
    
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

extension SendGridError: Debuggable {
    
    public var identifier: String {
        return errors?.compactMap { $0.field }.joined(separator: ", ") ?? "Unknown"
    }
    
    public var reason: String {
        return errors?.compactMap { $0.message }.joined(separator: ", ") ?? "Unknown Reason"
    }
    
}
