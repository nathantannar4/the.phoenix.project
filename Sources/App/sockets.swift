import Vapor

/// Register your application's socket routes here.
public func sockets(_ wss: NIOWebSocketServer) throws {
    
    let conversationSocketController = ConversationSocketController()
    try wss.register(collection: conversationSocketController)
    
}
