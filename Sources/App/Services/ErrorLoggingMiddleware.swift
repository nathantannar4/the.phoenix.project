//
//  ErrorLoggingMiddleware.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-20.
//

import Vapor

final class ErrorLoggingMiddleware: Middleware, Service {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        
        let logger = try request.make(Logger.self)
        
        let response: Future<Response>
        do {
            response = try next.respond(to: request)
        } catch let error {
            response = request.eventLoop.newFailedFuture(error: error)
            do {
                let workDir = DirectoryConfig.detect().workDir
                let logPath = Environment.LOG_PATH.convertToPathComponents().readable
                let path = URL(fileURLWithPath: workDir).appendingPathComponent(logPath, isDirectory: true)
                if !FileManager.default.fileExists(atPath: path.absoluteString) {
                    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
                }
                let url = path.appendingPathComponent("error.log")
                try error.localizedDescription.appendLineToURL(fileURL: url)
                logger.report(error: error)
            } catch (let error) {
                logger.report(error: error)
            }
        }
        
        return response
    }
    
}

extension ErrorLoggingMiddleware: ServiceType {
    
    static func makeService(for worker: Container) throws -> Self {
        return .init()
    }
    
}
