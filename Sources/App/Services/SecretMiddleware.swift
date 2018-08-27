//
//  SecretMiddleware.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-11.
//

import Vapor

/// Rejects requests that do not contain correct secret.
final class SecretMiddleware: Middleware, Service {
    
    /// The secret expected in the `"X-API-KEY"` header.
    let secret: String
    
    /// Creates a new `SecretMiddleware`.
    ///
    /// - parameters:
    ///     - secret: The secret expected in the `"X-API-KEY"` header.
    init(secret: String) {
        self.secret = secret
    }
    
    /// See `Middleware`.
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        guard request.http.headers.firstValue(name: .xApiKey) == secret else {
            throw Abort(.forbidden, reason: "Invalid X-API-KEY")
        }
        
        return try next.respond(to: request)
    }
}

extension HTTPHeaderName {
    
    /// Contains a secret key.
    ///
    /// `HTTPHeaderName` wrapper for "X-API-KEY".
    static var xApiKey: HTTPHeaderName {
        return .init("X-API-KEY")
    }
    
}

extension SecretMiddleware: ServiceType {
    
    /// See `ServiceType`.
    static func makeService(for worker: Container) throws -> SecretMiddleware {
        guard let secret = Environment.X_API_KEY else {
            throw Abort(.internalServerError, reason: "No $X-API-KEY set on environment. Use `export X-API-KEY=<secret>`")
        }
        return SecretMiddleware(secret: secret)
    }
    
}

