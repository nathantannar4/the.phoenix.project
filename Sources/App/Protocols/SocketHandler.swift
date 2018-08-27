//
//  SocketHandler.swift
//  App
//
//  Created by Nathan Tannar on 2018-08-15.
//

import Vapor

protocol SocketHandler {
    
    func onConnection()
    
    func onBinary(_ ws: WebSocket, _ data: Data)
    
    func onText(_ ws: WebSocket, _ text: String)
    
    func onError(_ ws: WebSocket, _ error: Error)
    
    func onCloseCode(_ code: WebSocketErrorCode)
    
    func onDisconnection()
    
}
