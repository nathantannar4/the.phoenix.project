//
//  SocketManager.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-15.
//

import Vapor

protocol SocketManager {
    
    associatedtype RoomID: Hashable
    associatedtype ConnectionID: Hashable
    
    typealias Room = SocketRoom<RoomID, ConnectionID>
    
    var rooms: Set<Room> { get set }
    
}
