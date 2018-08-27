//
//  SocketCollection.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-14.
//

import Vapor

protocol SocketCollection {
    
    /// Registers routes to the incoming socket.
    ///
    /// - parameters:
    ///     - router: `NIOWebSocketServer` to register any new routes to.
    func boot(wss: NIOWebSocketServer) throws
    
}

extension NIOWebSocketServer {
    /// Registers all of the routes in the group to this socket.
    ///
    /// - parameters:
    ///     - collection: `SocketCollection` to register.
    func register(collection: SocketCollection) throws {
        try collection.boot(wss: self)
    }
    
}
